%%% Gossip And Push Sum
%%% Authors: 
%%% Vaibhavi Deshpande
%%% Ishan Kunkolikar
-module ( gossip1 ).
-export( [ start_process/3 ] ).
-import(math,[sqrt/1, pow/2]).

start_process( NumNodes, Topology, Algorithm ) ->
    Nodes = [],
    case Topology of
        '2DGrid' -> 
        NumNodesNew = round(math:pow(round(sqrt(NumNodes)), 2));
        '3DImperfect' ->
        NumNodesNew = round(math:pow(round(pow(NumNodes, 1/3)), 3));
        true ->
        NumNodesNew = NumNodes
    end,
    case Algorithm of
        'Gossip' ->
            UpdatedNodes = build_nodes_gossip(NumNodesNew, Nodes),
            % io:fwrite(  "Updated Node: ~p~n",[UpdatedNodes] ),
            io:fwrite(  "Starting Time: ~p~n",[erlang:timestamp()] ),
            build_topology_gossip( NumNodesNew, UpdatedNodes, Topology );
        'PushSum' ->
            UpdatedNodes = build_nodes_pushsum(NumNodesNew, Nodes,1),
            io:fwrite(  "Starting Time: ~p~n",[erlang:timestamp()] ),
            build_topology_pushsum( NumNodesNew, UpdatedNodes, Topology )
    end.


build_nodes_gossip(0,_) -> [];
build_nodes_gossip ( NumNodes,  Nodes ) 
    when 
        NumNodes > 0 -> 
            ProcID = spawn( fun() -> create_node_gossip(0) end ),
            NewNodes = lists:append(Nodes,[ProcID]),
            build_nodes_gossip(NumNodes - 1,  NewNodes ) ++ [ProcID].

build_nodes_pushsum(0,_,_) -> [];
build_nodes_pushsum ( NumNodes,  Nodes, Counter ) 
    when 
        NumNodes > 0 -> 
            ProcID = spawn( fun() -> create_node_pushsum(0, Counter, 1, 0) end ),
            NewNodes = lists:append(Nodes,[ProcID]),
            build_nodes_pushsum(NumNodes - 1,  NewNodes ,Counter+1) ++ [ProcID].


create_node_gossip(Counter) ->
    receive
        { gossip, Message, GridMap } ->
            io:fwrite(  "Received Rumour: ~p~n",[Counter] ),
            Neighbours = maps:get(self(),GridMap),
            NeighboursLength = length(Neighbours),
            RandomProcess = lists:nth(rand:uniform(NeighboursLength), Neighbours),
            RandomProcess ! { gossip, Message, GridMap},
            if
                Counter == 10 ->
                    io:format("Stopping : ~p ~n", [self()]),
                    io:fwrite(  "Converging Time: ~p~n",[erlang:timestamp()] ),
                    exit(self(), kill);
                true ->
                    create_node_gossip(Counter+1)
            end
    end.

build_topology_gossip( NumNodes, Nodes, Topology ) ->
    case Topology of 
        'Full' -> 
            ListNeighbours = build_full_topology(NumNodes, Nodes) ,
            GridMap = maps:from_list(ListNeighbours),
            io:format("Grid Map: ~p~n", [GridMap]),
            start_gossip_algortihm(NumNodes, GridMap, Nodes);
        'Line' -> 
            ListNeighbours = build_line_topology(NumNodes, Nodes),
            GridMap = maps:from_list(ListNeighbours),
            io:format("Grid Map: ~p~n", [GridMap]),
            start_gossip_algortihm(NumNodes, GridMap, Nodes);
        '2DGrid' -> 
            ListNeighbors = build_2D_grid_topology(NumNodes, Nodes, NumNodes),
            GridMap = maps:from_list(ListNeighbors),
            io:format("~p~n", [GridMap]),
            start_gossip_algortihm(NumNodes, GridMap, Nodes);
        '3DImperfect' -> 
            ListNeighbors = build_3D_topology(NumNodes, Nodes, NumNodes),
            GridMap = maps:from_list(ListNeighbors),
            io:format("~p~n", [GridMap]),
            start_gossip_algortihm(NumNodes, GridMap, Nodes)
   end.

build_full_topology(0,_) -> [];
build_full_topology(NumNodes, Nodes) 
    when
         NumNodes > 0 ->
            NewTemp = Nodes,
            Element = lists:nth(NumNodes, NewTemp),
            Temp = lists:delete(Element, NewTemp),
            build_full_topology(NumNodes - 1, Nodes) ++ [{Element,Temp}].


build_line_topology(0,_) -> [];
build_line_topology(NumNodes,Nodes)
  when NumNodes > 0 ->
  Key = lists:nth(NumNodes,Nodes),
  if
    NumNodes == 1 ->
      build_line_topology(NumNodes-1,Nodes) ++ [{Key,[lists:nth(NumNodes+1,Nodes)]}];
    NumNodes == length(Nodes) ->
      build_line_topology(NumNodes-1,Nodes) ++ [{Key,[lists:nth(NumNodes-1,Nodes)]}];
    true ->
      build_line_topology(NumNodes-1,Nodes) ++ [{Key,[lists:nth(NumNodes-1,Nodes),lists:nth(NumNodes+1,Nodes)]}]
  end.

build_2D_grid_topology(0,_,_) -> [];
build_2D_grid_topology(NumNodes,Nodes,NumNodesTotal)
    when NumNodes > 0 ->
    TwoDGridSize = round(sqrt(NumNodesTotal)),
    io:format("grid ~p~n", [TwoDGridSize]),
    Grid = [[I,J] || I <- lists:seq(0, TwoDGridSize-1), J <- lists:seq(0, TwoDGridSize-1)],
    [I, J] = lists:nth(NumNodes,Grid),
    Key = lists:nth(NumNodes,Nodes),
    build_2D_grid_topology(NumNodes-1, Nodes,NumNodesTotal) ++ [{Key, check_if_exists(I, J, TwoDGridSize, Nodes,1) ++ check_if_exists(I, J, TwoDGridSize, Nodes,2) ++ check_if_exists(I, J, TwoDGridSize, Nodes,3) ++ check_if_exists(I, J, TwoDGridSize, Nodes,4)}].

check_if_exists (I, J, TwoDGridSize, Nodes, Position) ->
    case Position of 
        1 -> 
            if
                J + 1 < TwoDGridSize ->
                [lists:nth(I * TwoDGridSize + J + 1+1,Nodes)];
                true -> []
            end;
        2 -> 
            if
                J - 1 >= 0 ->
                [lists:nth(I * TwoDGridSize + J,Nodes)];
                true -> []
            end;
        3 -> 
              if
                I - 1 >= 0 ->
                [lists:nth((I - 1) * TwoDGridSize + J+1,Nodes)];
                true -> []
            end;
        4 -> 
            if
                I + 1 < TwoDGridSize ->
                [lists:nth((I + 1) * TwoDGridSize + J+1,Nodes)];
                true -> []
            end
   end.

start_gossip_algortihm(NumNodes, GridMap, Nodes) ->
    RandomProcess = lists:nth(rand:uniform(NumNodes), Nodes),
    RandomProcess ! { gossip, 'This is gossip', GridMap }.

build_topology_pushsum( NumNodes, Nodes, Topology ) ->
    case Topology of 
        'Full' -> 
            ListNeighbours = build_full_topology(NumNodes, Nodes) ,
            GridMap = maps:from_list(ListNeighbours),
            io:format("Grid Map: ~p~n", [GridMap]),
            start_pushsum(NumNodes, GridMap, Nodes);
        'Line' -> 
            ListNeighbours = build_line_topology(NumNodes, Nodes),
            GridMap = maps:from_list(ListNeighbours),
            io:format("Grid Map: ~p~n", [GridMap]),
            start_pushsum(NumNodes, GridMap, Nodes);
        '2DGrid' -> 
            ListNeighbors = build_2D_grid_topology(NumNodes, Nodes, NumNodes),
            GridMap = maps:from_list(ListNeighbors),
            io:format("Grid Map~p~n", [GridMap]),
            start_pushsum(NumNodes, GridMap, Nodes);
        '3DImperfect' -> 
            ListNeighbors = build_3D_topology(NumNodes, Nodes, NumNodes),
            GridMap = maps:from_list(ListNeighbors),
            io:format("~p~n", [GridMap]),
            start_pushsum(NumNodes, GridMap, Nodes)
   end.

create_node_pushsum(Counter, S_Node, W_Node, ConvergeCount) ->
    receive
        { pushsum, S_Received, W_Received, GridMap } ->
            io:fwrite(  "Received Rumour: ~p~n",[Counter] ),
            RatioOld = S_Node/W_Node,
            S_New = S_Node + S_Received,
            W_New = W_Node + W_Received,
            S_Send = S_New/2,
            W_Send = W_New/2,
            RatioNew = S_Send/W_Send,
            io:format("Transmitting: ~p S : ~p W : ~p Ratio: ~p~n ", [self() ,S_Send , W_Send ,RatioNew]),

            Neighbours = maps:get(self(),GridMap),
            NeighboursLength = length(Neighbours),
            RandomProcess = lists:nth(rand:uniform(NeighboursLength), Neighbours),
            RandomProcess ! { pushsum,S_Send,W_Send, GridMap},
            if
                ConvergeCount == 3 ->
                    io:format("Stopping : ~p ~n", [self()]),
                    io:fwrite(  "Converging Time: ~p~n",[erlang:timestamp()] ),
                    exit(self(), kill);
                abs(RatioNew - RatioOld) < 0.0000000001 ->
                    create_node_pushsum(Counter+1, S_Send, W_Send, ConvergeCount+1);
                true ->
                    create_node_pushsum(Counter+1, S_Send, W_Send, ConvergeCount)
            end
    end.   

start_pushsum(NumNodes, GridMap, Nodes) ->
    RandomProcess = lists:nth(rand:uniform(NumNodes), Nodes),
    RandomProcess ! { pushsum, 0,0, GridMap }.

build_3D_topology(0,_,_) -> [];
build_3D_topology(NumNodes,Nodes,TotalNumberOfNodes)
    when NumNodes > 0 ->
    GridSize = round(pow(TotalNumberOfNodes, 1/3)),
    Prods = [[K,I,J] || K <- lists:seq(0, GridSize-1), I <- lists:seq(0, GridSize-1), J <- lists:seq(0, GridSize-1)],
    %io:format("~p~n",[Prods]),
    [K, I, J] = lists:nth(NumNodes,Prods),
    io:format("~p~p~p~n",[K,I,J]),
    Key = lists:nth(NumNodes,Nodes),
    Neighbor_list = check_if_exists_3d(I, J, K, GridSize, Nodes,1) ++ check_if_exists_3d(I, J, K, GridSize, Nodes,2) ++ check_if_exists_3d(I, J, K, GridSize, Nodes,3) ++ check_if_exists_3d(I, J, K, GridSize, Nodes,4) ++ check_if_exists_3d(I, J, K, GridSize, Nodes,5) ++ check_if_exists_3d(I, J, K, GridSize, Nodes,6),
    Non_neighbor_list = Nodes -- Neighbor_list -- [Key],
    io:format("~p~n",[Non_neighbor_list]),
    Random_Node = lists:nth(rand:uniform(length(Non_neighbor_list)), Non_neighbor_list),
    io:format("~p~n",[Random_Node]),
    io:format("~p~p~p~n",[K,I,J]),
    build_3D_topology(NumNodes-1, Nodes, TotalNumberOfNodes) ++ [{Key, Neighbor_list ++ [Random_Node]}].

check_if_exists_3d(I, J, K, ThreeDGridSize, Nodes, Position) ->
    case Position of 
        1 -> 
            if
                J + 1 < ThreeDGridSize ->
                [lists:nth(K * ThreeDGridSize * ThreeDGridSize + I * ThreeDGridSize + J + 1 + 1,Nodes)];
                true -> []
            end;
        2 -> 
            if
                J - 1 >= 0 ->
                [lists:nth(K * ThreeDGridSize * ThreeDGridSize + I * ThreeDGridSize + J - 1 + 1,Nodes)];
                true -> []
            end;
        3 -> 
            if
                I - 1 >= 0 ->
                [lists:nth(K * ThreeDGridSize * ThreeDGridSize + (I - 1) * ThreeDGridSize + J + 1,Nodes)];
                true -> []
            end;
        4 -> 
            if
                I + 1 < ThreeDGridSize ->
                [lists:nth(K * ThreeDGridSize * ThreeDGridSize + (I + 1) * ThreeDGridSize + J + 1,Nodes)];
                true -> []
            end;
        5 -> 
            if
                K - 1 >= 0 ->
                [lists:nth((K - 1) * ThreeDGridSize * ThreeDGridSize + I * ThreeDGridSize + J + 1,Nodes)];
                true -> []
            end;
        6 -> 
            if
                K + 1 < ThreeDGridSize ->
                [lists:nth((K + 1) * ThreeDGridSize * ThreeDGridSize + I * ThreeDGridSize + J + 1,Nodes)];
                true -> []
            end
   end.
