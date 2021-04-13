defmodule Gui do
    def build_view(state) do 
        clear_console()
        state
        |> view()
        |> IO.write()
        state
    end

    def clear_console() do
        [ IO.ANSI.clear(), IO.ANSI.cursor(1,0) ]    
        |> IO.write()
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
       ["\n\n", "angeforderte Ressourcen \n\n\t", resource, ": ", "#{amount}", "\n\n\n", "benoetigte Ressourcen \n\n", req,  "\n\n" ]
    end

    def view_result( _state ), do: ["\n\n"]

end