import FluentSQLite
import Vapor

final class PokemonController {
    /// Lists all known pokemon in our pokedex.
    func index(_ req: Request) throws -> Future<[Pokemon]> {
        return Pokemon.query(on: req).all()
    }

    /// Stores a newly discovered pokemon in our pokedex.
    func create(_ req: Request) throws -> Future<Pokemon> {
        /// Decode a Pokemon from the HTTP request body
        return try req.content.decode(Pokemon.self).flatMap { pokemon in
            /// Check to see if the pokemon already exists
            return Pokemon.query(on: req).filter(\Pokemon.name == pokemon.name).count().flatMap(to: Bool.self) { count in
                /// Ensure number of Pokemon with the same name is zero
                guard count == 0 else {
                    throw Abort(.badRequest, reason: "You already caught \(pokemon.name).")
                }

                /// Check if the pokemon is real. This will throw an error aborting
                /// the request if the pokemon is not real.
                return try req.make(PokeAPI.self).verifyName(pokemon.name)
            }.flatMap(to: Pokemon.self) { nameVerified in
                /// Ensure the name verification returned true, or throw an error
                guard nameVerified else {
                    throw Abort(.badRequest, reason: "Invalid Pokemon name.")
                }

                /// save the pokemon
                return pokemon.save(on: req)
            }
        }
    }
}


