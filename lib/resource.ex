defmodule Resource do
    defstruct [
        
        building: "",
        extraction_rate: 0,
        production_rate: 0,
        inputs: [%{resource: "", quantity: 0}],
        output: 0,
        type: :compound
    ]

    def init do
        %{
            "Eisenerz" => %Resource{building: "MinerMk1", extraction_rate: 30, type: :source},
            "Eisenbarren" => %Resource{building: "Schmelzofen", production_rate: 30, output: 1, inputs: [%{resource: "Eisenerz", quantity: 1}]},
            "Eisenplatten" => %Resource{building: "Konstruktor", production_rate: 20, output: 2, inputs: [%{resource: "Eisenbarren", quantity: 3}]},
            "Eisenstangen" => %Resource{building: "Konstruktor", production_rate: 15, output: 1, inputs: [%{resource: "Eisenbarren", quantity: 1}]},
            "Schrauben" => %Resource{building: "Konstruktor", production_rate: 40, output: 4, inputs: [%{resource: "Eisenstangen", quantity: 1}]},
            "VerstaerkteEisenplatten" => %Resource{building: "Manufaktor", production_rate: 2, output: 1, inputs: [%{resource: "Eisenplatten", quantity: 6}, %{resource: "Schrauben", quantity: 12}]}
            }
    end
end