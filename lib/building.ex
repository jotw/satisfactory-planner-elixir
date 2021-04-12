defmodule Building do
    defstruct [

        number_of_inputs: 0,
        energy_consumption: 0
    ]

    def init() do
        %{
            "Schmelzofen" => %Building{number_of_inputs: 1, energy_consumption: 4},
            "Konstruktor" => %Building{number_of_inputs: 1, energy_consumption: 4},
            "Manufaktor" => %Building{number_of_inputs: 2, energy_consumption: 15}
            }
    end
end