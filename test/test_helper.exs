exclude_slow =
  if System.get_env("RUN_SLOW_TESTS") in ["true", "1"] do
    []
  else
    [:slow]
  end

ExUnit.start(exclude: exclude_slow)
