defmodule Calculator do
    import Gui

    defstruct [
        buildings: %{},
        resources: %{},
        request: {},
        required_buildings: %{},
        required_resources: %{}
    ]

    def test( resource_name, quantity ) do
        
        state = init()
        state = Map.put( state, :request, {resource_name, quantity} )
        resources = state.resources

        number_of_required_buildings = calculate_number_of_required_buildings(resources[resource_name], quantity )
        resource = resources[resource_name]
        
        calculate_required_input_resources( number_of_required_buildings, resource, resource.inputs )
        |> request_resources(state)
        |> view_result()
    end    

    # create an initial state
    def init() do 
        %Calculator{
            resources: Resource.init(),
            buildings: Map.merge( Building.init(), Miner.init )
        }
    end

    # inital call without paramters. Creates an inital state and starts loop
    def run() do
        init()
        |> loop()
    end

    # exit application loop
    def loop( :quit ), do: :quit

    # application loop
    def loop( state ) do
        
        # build view and handle input
        state
        |> build_view()
        |> handle_input()
        
        # let it loop
        |> loop()
    end
     
    # handle input and execute command
    def handle_input(state) do
        command = IO.gets( ">" )
        command
        |> String.split()
        |> validate_input(state)
        |> handle_input(state)
    end

    # @todo: unschoen, da validate_input und handle_input für dieses matching quasi redundant!
    def validate_input( ["q" <> _], _state ), do: ["q"]

    def validate_input([resource_name, quantity], state) do
       case Map.has_key?(state.resources, resource_name) and Integer.parse(quantity) do
            {quantity, ""} -> [resource_name, quantity]
            :error -> [:error, "Bitte geben eine Zahl ein!\n"]     
            false -> [:error, "Die Resource exisitert nicht!\n"]    
       end
    end

    # handle quit. If user input is "q" or anything longer
    def handle_input( ["q" <> _], _state ), do: :quit

    # handle error. If user input is invalid
    def handle_input( [:error, message], state )  do
        clear_console()
        IO.puts(message)
        IO.gets( "Zum Fortsetzen return druecken" )
        state
    end   

    # handle calculation request. If user input is resource name and number of required inputs
    def handle_input( [resource_name, quantity], state ) do
       state = Map.put( state, :request, {resource_name, quantity} )
       request_resources( [%{resource: resource_name, quantity: quantity}], state )
    end

    # termination function for calculation recursion
    def request_resources( [], state ) do
        state
    end

    # get required buildings and input resources and perform these calculations for the input resources as well and perform these calc.... recursion until list of resources is empty)
    def request_resources( [%{resource: resource_name, quantity: quantity} | tail ], state  = %{resources: resources} ) do
        resource = resources[resource_name]
        state = save_request(resource_name, quantity, state, Map.has_key?(state.required_resources, resource_name))
        state = perform_resource_calculations(resource, quantity, state)
        state = request_resources(List.flatten([tail]), state)
        state
    end

    def perform_resource_calculations(resource, quantity, state) when resource.type == :compound do
        calculate_number_of_required_buildings(resource, quantity )
        |> calculate_required_input_resources( resource, resource.inputs )
        |> request_resources( state)
    end

    def perform_resource_calculations(resource, _quantity, state) when resource.type == :source, do: state

    # save the requested resource to state (for later output)
    def save_request(resource_name, quantity, state, _resource_already_requested = true) do
        required_resources = Map.update!(state.required_resources, resource_name, &(&1+quantity))
        Map.put(state, :required_resources, required_resources)
    end

    def save_request(resource_name, quantity, state,  _resource_already_requested = false) do
        required_resources = Map.put(state.required_resources, resource_name, quantity)
        Map.put(state, :required_resources, required_resources)
    end

    # calculate number of required buildings
    def calculate_number_of_required_buildings(%{production_rate: production_rate}, quantity ), do: (quantity / production_rate) 

    ## termination function. if list of input resources is empty
    def calculate_required_input_resources(_, _, [] ) do
        []
    end

    # calculate type and number of required input resources
    def calculate_required_input_resources(number_of_required_buildings, resource = %{production_rate: production_rate, output: output}, [head | tail] ) do
        result = [%{resource: head.resource, quantity: (number_of_required_buildings * (production_rate * head.quantity) / output)}]
        List.flatten([calculate_required_input_resources(number_of_required_buildings, resource, tail ) | result])
    end    
      
end