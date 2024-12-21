class FactoryResponse
  def self.create_response(origin:, response:, type:)
    return PokemonResponse.new(origin:, response:) if type == "success"

    PokemonFailedResponse.new(response:)
  end
end
