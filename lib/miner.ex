defmodule Miner do
    defstruct [
        extraction_rate: 0,
        energy_consumption: 0
    ]

    def init() do
        %{
            "MinerMk1" => %Miner{extraction_rate: 1, energy_consumption: 4}
        }
    end
end
