import gleam/dict
import gleam/int
import lenient_parse/internal/whitespace
import prng/random
import prng/seed

// TODO: Make sure poison produces all characters
// TODO: Ability to poison middle of integer string

pub fn random_integer_string() -> String {
  let #(integer_string, _) =
    random_integer_generator() |> random.step(seed.random())

  integer_string
}

fn random_integer_generator() -> random.Generator(String) {
  use leading_whitespace <- random.then(maybe_whitespace_generator())
  use trailing_whitespace <- random.then(maybe_whitespace_generator())

  use underscore_1 <- random.then(maybe_underscore_generator())
  use underscore_2 <- random.then(maybe_underscore_generator())

  use poison_1 <- random.then(maybe_poison_generator())
  use poison_2 <- random.then(maybe_poison_generator())
  use poison_3 <- random.then(maybe_poison_generator())
  use poison_4 <- random.then(maybe_poison_generator())
  use poison_5 <- random.then(maybe_poison_generator())
  use poison_6 <- random.then(maybe_poison_generator())

  use integer_1 <- random.then(maybe_integer_string_generator())
  use integer_2 <- random.then(maybe_integer_string_generator())
  use sign <- random.then(maybe_sign_generator())

  random.constant(
    poison_1
    <> leading_whitespace
    <> poison_2
    <> sign
    <> poison_3
    <> underscore_1
    <> integer_1
    <> poison_4
    <> integer_2
    <> underscore_2
    <> poison_5
    <> trailing_whitespace
    <> poison_6,
  )
}

fn maybe_underscore_generator() -> random.Generator(String) {
  random.weighted(#(0.9, ""), [#(0.1, "_")])
}

fn maybe_whitespace_generator() -> random.Generator(String) {
  let characters = whitespace.character_dict() |> dict.keys

  let assert Ok(character_generator_1) = random.try_uniform(characters)
  let assert Ok(character_generator_2) = random.try_uniform(characters)
  let assert Ok(character_generator_3) = random.try_uniform(characters)

  use character_1 <- random.then(character_generator_1)
  use character_2 <- random.then(character_generator_2)
  use character_3 <- random.then(character_generator_3)

  let whitespace = character_1 <> character_2 <> character_3

  random.weighted(#(0.1, ""), [#(0.9, whitespace)])
}

fn maybe_sign_generator() -> random.Generator(String) {
  let characters = ["+", "-"]
  let assert Ok(random_character_generator) = random.try_uniform(characters)
  let character = random_character_generator |> random.random_sample()
  random.choose("", character)
}

// TODO: Cleanup
// TODO: Store base prefixes in constants
fn maybe_integer_string_generator() -> random.Generator(String) {
  let base_prefixes = ["0b", "0B", "0o", "0O", "0x", "0X"]
  let assert Ok(base_prefix) = random.try_uniform(base_prefixes)
  use base_prefix <- random.then(base_prefix)

  let integer = int.random(10_000_000_000_000)

  let base_conversion_function = case base_prefix {
    "0b" | "0B" -> int.to_base2
    "0o" | "0O" -> int.to_base8
    "0x" | "0X" -> int.to_base16
    _ -> panic as "Invalid base prefix"
  }

  let integer_in_base_string = integer |> base_conversion_function

  use integer_string <- random.then(random.choose(
    integer_in_base_string,
    integer |> int.to_string,
  ))
  use integer_string <- random.then(random.choose("", integer_string))
  use base_prefix <- random.then(random.choose("", base_prefix))

  random.constant(base_prefix <> integer_string)
}

fn maybe_poison_generator() -> random.Generator(String) {
  let random_character_generator = random.fixed_size_string(1)
  let #(random_character, _) =
    random_character_generator |> random.step(seed.random())
  random.weighted(#(0.9, ""), [#(0.1, random_character)])
}
