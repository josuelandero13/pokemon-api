class PokemonConnection
  def client(read_timeout = 30)
    Faraday.new(url: "https://pokeapi.co/api/v2/") do |conn|
      conn.options.open_timeout = 30
      conn.options.read_timeout = read_timeout
      conn.request :json
      conn.response :logger, nil, { headers: false, bodies: false, errors: false }
      conn.response :json
      conn.adapter :net_http
    end
  end

  def get_pokemon(pokemon_name:)
    client.get("pokemon/#{pokemon_name}")
  rescue Faraday::Error => e
    { "error" => e }
  end
end
