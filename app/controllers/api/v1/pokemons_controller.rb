class Api::V1::PokemonsController < ApplicationController
  def pokemon
    if params[:pokemon_name].present?
      response = get_pokemon(pokemon_name: params[:pokemon_name])
      render json: response.pokemon_body, status: response.status
    else
      render json:  { "error" => "Please provide a valid parameter." },
             status: :unprocessable_entity
    end
  end

  private

  def get_pokemon(pokemon_name:)
    PokemonService.new(pokemon_name:).get_pokemon
  end
end
