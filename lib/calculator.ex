defmodule Calculator do
    defstruct [
        buildings: %{},
        resources: %{},
        request: {},
        required_buildings: %{},
        required_resources: %{}
    ]


    # create an initial state
    def init() do 
        %Calculator{
            resources: Resource.init(),
            buildings: Map.merge( Building.init(), Miner.init )
        }
    end

    # inital call without paramters. Creates an inital state starts loop
    def run() do
        init()
        |> loop()
    end

    # exit application loop
    def loop( :quit ), do: :quit

    # application loop
    def loop( state ) do
        # clear console
        [ IO.ANSI.clear(), IO.ANSI.cursor(1,0) ]    
        |> IO.write()
        
        # build view
        state
        |> view()
        |> IO.write()

        # handle input and execute command
        command = IO.gets( ">" )
        command
        |> String.split()
        |> handle_input(state)

        # let it loop
        |> loop()
    
    end

    # handle quit. If user input is "q" or anything longer
    def handle_input( ["q" <> _], _state ), do: :quit
        
    # handle calculation request. If user input is resource name and number of required inputs
    def handle_input( [resource_name, required_amount], state  = %{resources: resources} ) do
       {required_amount, ""} = Integer.parse(required_amount)
       state = Map.put( state, :request, {resource_name, required_amount} )
       calculate_resources( [%{resource: resource_name, amount: required_amount}], state )
    end

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

    


    def view( state ) do
        [ view_header(), view_result(state), view_command_line() ]
    end

    def view_command_line() do
        ["Gebe Resource und gewuenschte Anzahl pro Minute an",
        "\n", 
        "(z.B. Eisenplatten 10)", ":" 
        ]
    end

    def view_header() do
        [ "S A T I S F A C T O R Y  P L A N N E R", 
        "\n", 
        "Einfache Fabriken Planung \n\n" ]
    end

    def view_result( state = %{request: {resource, amount}, required_resources: required_resources} ) do
       req = Enum.map(required_resources, fn {req_resource, req_amount} -> ["\t", req_resource, ":", "#{req_amount}", "\n" ] end)
       ["\n\n", resource, ": ", "#{amount}", "\n\n", "benoetigte Ressourcen \n", req,  "\n\n" ]
    end

    def view_result( _state ), do: ["\n\n"]

      
end