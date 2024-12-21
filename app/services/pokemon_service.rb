class PokemonService
  attr_reader :pokemon_name

  def initialize(pokemon_name:)
    @pokemon_name = pokemon_name
  end

  def get_pokemon
    client = PokemonConnection.new
    proxy = PokemonProxy.new(client)
    proxy.get_pokemon(pokemon_name:)
  end
end
