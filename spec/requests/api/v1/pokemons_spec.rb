require 'rails_helper'

RSpec.describe Api::V1::PokemonsController, type: :request, vcr: { record: :new_episodes } do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:pokemon_name) { 'pikachu' }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
  end

  describe 'GET /api/v1/pokemon' do
    context 'with a valid pokemon' do
      it 'returns data from the client on the first request and caches it for subsequent requests' do
        # first call - fetch data from the client
        get "/api/v1/pokemon?pokemon_name=#{pokemon_name}"
        expect(response.status).to eq(200)
        pokemon = parse_response(response.body)
        expect(pokemon['origin']).to eq('client_call')
        pokemon_information(pokemon)
        expect(Rails.cache.exist?("pokemon_cached/#{pokemon_name}")).to eq(true)

        # second call - fetch data from cache
        get "/api/v1/pokemon?pokemon_name=#{pokemon_name}"
        pokemon = parse_response(response.body)
        expect(pokemon['origin']).to eq('on_cache')
        pokemon_information(pokemon)
      end
    end

    context 'with an invalid pokemon' do
      it 'returns an error' do
        get '/api/v1/pokemon?pokemon_name=unknown_pokemon'
        error = parse_response(response.body)
        expect(error['error']).to eq('Not Found')
        expect(error['status']).to eq(404)
      end
    end

    context 'with invalid parameters' do
      it 'returns an error' do
        get '/api/v1/pokemon?pokemon_namess=unknown_pokemon'
        error = parse_response(response.body)
        expect(error['error']).to eq('Please provide a valid parameter.')
      end
    end
  end

  # Helper methods
  def pokemon_information(pokemon)
    expect(pokemon['name']).to eq('pikachu')
    expect(pokemon['weight']).to eq(60)
    expect(pokemon['types']).to eq([ 'electric' ])
    expect(pokemon['stats']).to eq([
      'hp: 35',
      'attack: 55',
      'defense: 40',
      'special-attack: 50',
      'special-defense: 50',
      'speed: 90'
    ])
    expect(pokemon['consulted_at']).to be_present
  end

  def parse_response(response)
    JSON.parse(response)
  end
end
