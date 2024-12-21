class PokemonFailedResponse
  attr_reader :response

  def initialize(response:)
    @response = response
    @pokemon_body = pokemon_body
  end

  def pokemon_body
    {
      'error': response.body,
      'status': response.status
    }
  end

  def status
    response.status
  end
end
