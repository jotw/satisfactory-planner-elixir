defmodule CalculatorTest do
    use ExUnit.Case 
    doctest Calculator

    setup_all do
        
    end

    setup do
        
    end
    
    test "berechnung der benoetogten gebaeude" do
        nr_of_buildings = Calculator.calculate_number_of_required_buildings(150, 30)
        assert nr_of_buildings == 5
    end

end