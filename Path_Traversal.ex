defmodule Task2PathTraversal do
 
@moduledoc """
  A module that implements functions for
  path planning algorithm and travels the path
  """

  @cell_map %{ 1 => [4],
                2 => [3, 5],
                3 => [2],
                4 => [1, 7],
                5 => [2, 6, 8],
                6 => [5, 9],
                7 => [4, 8],
                8 => [5, 7],
                9 => [6]
  }

  @matrix_of_sum [
    [55,100, 85],
    [75, 77, 78],
    [85, 50, 145]
  ]

  @doc """
  #Function name:
          get_locations
  #Inputs:
          A 2d matrix namely matrix_of_sum containing two digit numbers
  #Output:
          List of locations of the valid_sum which should be in ascending order
  #Details:
          To find the cell locations containing valid_sum in the matrix
  #Example call:
          Check Task 2 Document
  """
  def get_locations(matrix_of_sum \\ @matrix_of_sum) do
    list=matrix_of_sum |> List.flatten 
  Enum.with_index(list, fn element, index -> if is_integer(element) , do: index end)
  |> Enum.filter(fn x-> if is_integer(x) , do: x end) |> Enum.map(fn x-> x+1 end)
 
  end

  @doc """
  #Function name:
          cell_traversal
  #Inputs:
          cell_map which contains all paths as well as the start and goal locations
  #Output:
          List containing the path from start to goal location
  #Details:
          To find the path from start to goal location
  #Example call:
          Check Task 2 Document
  """
  
   def helper(cell_map, start,prev_start, goal)  do
   list=Enum.reject(Map.fetch!(cell_map,start),fn x-> x==prev_start end)
   
        if (validpath(cell_map,start,goal)==goal) do
      [prev_start]++[start]++[validpath(cell_map,start,goal)]
      else
       if (list==[]) do
       nil
       end
      
        if  (Enum.find_value([start] ++ Enum.map(list,fn x-> helper(cell_map,x,start,goal) end),fn x-> x==nil end)) do
      []
      else
     
        if (Enum.filter(([start] ++ Enum.map(list,fn x-> helper(cell_map,x,start,goal) end)) -- [start],fn x-> x != [] end))==[] do
    []
    else
         [start] ++ Enum.map(list,fn x-> helper(cell_map,x,start,goal) end)
    
   
     end
      
     end
     end
     
     end
     
  def cell_traversal(map \\ @cell_map, start, goal) do
       
          if (start == goal)  do
          [start] 
           
          else
          if (validpath(map,start,goal)==goal) do
            [start]++[validpath(map,start,goal)]
          else
   visited=Map.fetch!(map,start)
   
   new_map= if (Enum.map(Enum.to_list(1..9),fn x->Enum.map(Enum.to_list(1..9),fn y->[y,x] end)end) |> List.flatten |> Enum.chunk_every(2) |> Enum.map(fn [x,y]-> if y != x and  Map.fetch!(map,x)==Map.fetch!(map,y) , do: Map.replace(map,x,[]) end) |> Enum.uniq |>Enum.reject(fn x-> x==nil end)|> Enum.drop_every(2)|> Enum.count)==1 do
    Enum.map(Enum.to_list(1..9),fn x->Enum.map(Enum.to_list(1..9),fn y->[y,x] end)end) |> List.flatten |> Enum.chunk_every(2) |> Enum.map(fn [x,y]-> if y != x and   Map.fetch!(map,x)==Map.fetch!(map,y) , do: Map.replace(map,x,[]) end) |> Enum.uniq |>Enum.reject(fn x-> x==nil end)|> Enum.drop_every(2) |> List.first
    else
    if (Enum.map(Enum.to_list(1..9),fn x->Enum.map(Enum.to_list(1..9),fn y->[y,x] end)end) |> List.flatten |> Enum.chunk_every(2) |> Enum.map(fn [x,y]-> if y != x and  Map.fetch!(map,x)==Map.fetch!(map,y) , do: Map.replace(map,x,[]) end) |> Enum.uniq |>Enum.reject(fn x-> x==nil end)|> Enum.drop_every(2)|> Enum.count)==0 do
    Enum.map([1,2,3,4,5,6,7,8,9],fn x-> Map.fetch!(map,x) end) |> Enum.map(fn x-> x -- visited end) |> Enum.with_index(fn element,index->{index+1,element} end) |> Map.new
    else
    [a,b]=Enum.map(Enum.to_list(1..9),fn x->Enum.map(Enum.to_list(1..9),fn y->[y,x] end)end) |> List.flatten |> Enum.chunk_every(2) |> Enum.map(fn [x,y]-> if y != x and   Map.fetch!(map,x)==Map.fetch!(map,y) , do: Map.replace(map,x,[]) end) |> Enum.uniq |>Enum.reject(fn x-> x==nil end)|> Enum.drop_every(2)
    Map.merge(a,b,fn _k,v1,v2->if v1==[] and v2 != [] , do:  v2=[], else: if v2==[] and v1 != [] , do: v1=[], else: v1  end)
    end
    end


[start]++Enum.map(Map.fetch!(map,start),fn x-> helper(new_map,x,start,goal) end)  |> List.flatten |> Enum.uniq |>Enum.reject(fn x-> x== nil end) |> dedup(goal)
       
     
       end
      end
         
  end
  
  def check(cell_map) do
  list=Enum.map(Enum.to_list(1..9),fn x->Enum.map(Enum.to_list(1..9),fn y->[y,x] end)end) |> List.flatten |> Enum.chunk_every(2)

  Enum.map(list,fn [i,j]->cell_traversal(cell_map,i,j) end)
  end
  
   defp validpath(cell_map,start,goal) do
       (Enum.find(Map.fetch!(cell_map,start),fn x-> x==goal end))
end



 defp dedup(list,goal) do
    if  (List.last(list))!=goal do
  newlist=List.delete_at(list,-1)
     if (List.last(newlist))!=goal do
     dedup(newlist,goal)
     else
    newlist
     end
     else
     list
     end
  end
  


  @doc """
  #Function name:
          traverse
  #Inputs:
          a list (this will be generated in grid_traversal function) and the cell_map
  #Output:
          List of lists containing paths starting from the 1st cell and visiting every cell containing valid_sum
  #Details:
          To find shortest path from first cell to all valid_sum’s locations
  #Example call:
          Check Task 2 Document
  """
  def traverse(list, cell_map) do
 
     if list==[1] and Enum.count(list)==1 do
     [list]
     else
     if Enum.count(list)==2 do
     [x,y]=list  
     [cell_traversal(cell_map,x,y)] 
     else
     if Enum.count(list)>2 do
     if Enum.at(list,0)==1 and Enum.at(list,1)==1 do
     list9=[1]++list
     newlist= Enum.map(list9,fn x->if x != 1 and x != List.last(list), do: List.duplicate(x,2) end)
    list2= List.replace_at(newlist,0,1)
    list3=List.replace_at(list2,1,1)
    list4=List.replace_at(list3,2,1)
           List.replace_at(list4,-1,List.last(list)) |> List.flatten |> Enum.chunk_every(2) |> Enum.map(fn [x,y] ->           
           cell_traversal(cell_map,x,y) end)
    else
    newlist= Enum.map(list,fn x->if x != 1 and x != List.last(list), do: List.duplicate(x,2) end)
    list2= List.replace_at(newlist,0,1)
     List.replace_at(list2,-1,List.last(list)) |> List.flatten |> Enum.chunk_every(2) |> Enum.map(fn [x,y] ->           
           cell_traversal(cell_map,x,y) end)
     end
     end
     end
     
       end
     
         

           end
          

  @doc """
  #Function name:
          grid_traversal
  #Inputs:
          cell_map and matrix_of_sum
  #Output:
          List of keyword lists containing valid_sum locations along with paths obtained from traverse function
  #Details:
          Driver function which calls the get_locations and traverse function and returns the output in required format
  #Example call:
          Check Task 2 Document
  """
  def grid_traversal(cell_map \\ @cell_map,matrix_of_sum \\ @matrix_of_sum) do
    [1] ++ get_locations(matrix_of_sum)
    |> traverse(cell_map)
    |> Enum.map(fn path_list ->
        [{ Enum.at(path_list, -1)
           |> Integer.to_string()
           |> String.to_atom(), path_list}]
        end)
  end

end
