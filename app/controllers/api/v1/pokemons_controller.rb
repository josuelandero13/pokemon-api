class Api::V1::PokemonsController < ApplicationController
  def pokemon
    if params[:pokemon_name].present?
      response = get_pokemon(pokemon_name: params[:pokemon_name])
      render json: response, status: :ok
    else
      render json:  { "error" => "Please provide a valid parameter." },
             status: :unprocessable_entity
    end
  end

  private

  def get_pokemon(pokemon_name:)
    GetPokemonService.new(pokemon_name:).call
  end
end
