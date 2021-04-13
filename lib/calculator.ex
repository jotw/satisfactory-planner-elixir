defmodule Calculator do
    import Gui

    defstruct [
        buildings: %{},
        resources: %{},
        request: {},
        required_buildings: %{},
        required_resources: %{}
    ]

    def test( resource_name, required_amount ) do
        
        state = init()
        state = Map.put( state, :request, {resource_name, required_amount} )
        resources = state.resources

        number_of_required_buildings = calculate_number_of_required_buildings(resources[resource_name], required_amount )
        resource = resources[resource_name]
        
        calculate_required_resources_per_minute( number_of_required_buildings, resource, resource.inputs )
        |> calculate_resources(state)
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
        |> validate_input()
        |> handle_input(state)
    end

    # @todo: unschoen, da validate_input und handle_input für dieses matching quasi redundant!
    def validate_input( ["q" <> _] ), do: ["q"]

    def validate_input([resource_name, required_amount]) do
       case Integer.parse(required_amount) do
          {required_amount, ""} -> [resource_name, required_amount]
          :error -> [:error, "Die Menge der Resourcen muss eine Ganzzahl sein!\n"]
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
    def handle_input( [resource_name, required_amount], state  = %{resources: resources} ) do
       state = Map.put( state, :request, {resource_name, required_amount} )
       calculate_resources( [%{resource: resource_name, amount: required_amount}], state )
    end

    # termination function for calculation loop
    def calculate_resources( [], state ) do
        state
    end

    # calculation resources in a calculation loop
    def calculate_resources( [%{resource: resource_name, amount: required_amount} | tail ], state  = %{resources: resources} ) do
        resource = resources[resource_name]
        state = add_request(resource_name, required_amount, state)
        state = if (resource.type == :compound) do
            
            number_of_required_buildings = calculate_number_of_required_buildings(resource, required_amount )
            resource = resources[resource_name]
            
            calced = calculate_required_resources_per_minute( number_of_required_buildings, resource, resource.inputs )
            calculate_resources(calced, state)
        else 
            state
        end
        state = calculate_resources(List.flatten([tail]), state)
        
    end

    # save the requested resource
    def add_request(resource, amount, state) do
        
         state = if Map.has_key?(state.required_resources, resource) do

             required_resources = state.required_resources
             required_resources = Map.put(required_resources, resource, (required_resources[resource] + amount))
             %{state |  required_resources: required_resources}
             
         else 

            required_resources = state.required_resources
            required_resources = Map.put(required_resources, resource, amount)
            %{state |  required_resources: required_resources}
        end
        state
    end

    # calculate number of required buildings
    def calculate_number_of_required_buildings(%{production_rate: production_rate}, required_amount ), do: (required_amount / production_rate) 

    ## termination function. if list of input resources is empty
    def calculate_required_resources_per_minute(_, _, [] ) do
        []
    end

    # calculate number of required input resources 
    def calculate_required_resources_per_minute(number_of_required_buildings, resource = %{production_rate: production_rate, output: output}, [head | tail] ) do
        result = [%{resource: head.resource, amount: (number_of_required_buildings * (production_rate * head.amount) / output)}]
        List.flatten([calculate_required_resources_per_minute(number_of_required_buildings, resource, tail ) | result])
    end    
      
end