class PokemonProxy
  EXPIRATION = 24.hours.freeze

  attr_reader :client, :cache

  def initialize(client)
    @client = client
    @cache = Rails.cache
  end

  def get_pokemon(pokemon_name:)
    cache_key = "pokemon_cached/#{pokemon_name}"

    return response_pokemon("on_cache", cache.read(cache_key), "success") if cache.exist?(cache_key)

    response = client.get_pokemon(pokemon_name:)

    handle_pokemon_reponse(response, pokemon_name:)
  end

  private

  def handle_pokemon_reponse(response, pokemon_name:)
    return response_pokemon("client_call", response, "failed") unless response.status == 200

    response.body["consulted_at"] = Time.now.utc.strftime("%FT%T")
    cache.write(
      "pokemon_cached/#{pokemon_name}", response, expires_in: EXPIRATION
    )
    response_pokemon("client_call", response, "success")
  end

  def response_pokemon(origin, response, type)
    FactoryResponse.create_response(origin: origin, response:, type: type)
  end
end
