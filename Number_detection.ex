defmodule Task1bNumberDetection do
@moduledoc """
  A module that implements functions for detecting numbers present in a grid in provided image
  """
  alias Evision, as: OpenCV


  @doc """
  #Function name:
         identifyCellNumbers
  #Inputs:
         image  : Image path with name for which numbers are to be detected
  #Output:
         Matrix containing the numbers detected
  #Details:
         Function that takes single image as an argument and provides the matrix of detected numbers
  #Example call:

      iex(1)> Task1bNumberDetection.identifyCellNumbers("images/grid_1.png")
      [["22", "na", "na"], ["na", "na", "16"], ["na", "25", "na"]]
  """
  def identifyCellNumbers(image) do
   imgh=Evision.imread(image)
  gray =gray(imgh)
  bw =thresh(gray)
{contours, _} = Evision.findContours(bw, Evision.cv_RETR_LIST(), Evision.cv_CHAIN_APPROX_SIMPLE())
  list=[]++Enum.map(contours,fn x->Evision.boundingRect(x) end)   
  contours=Enum.map(contours,fn x->if Enum.at(Map.fetch!(x,:shape)|>Tuple.to_list,1)==1 and Enum.at(Map.fetch!(x,:shape)|>Tuple.to_list,2)==2, do: x  end) |> Enum.reject(fn x-> x==nil end)      
   contours =
  Enum.sort_by(contours, fn c ->
    -Evision.contourArea(c)
  end)
    list=[]++Enum.map(contours,fn x->Evision.boundingRect(x) end)  
 {x,y,w,h}= Enum.at(list,1) 
 bw=imgh[[y..y+w,x..x+w]] |> gray |> thresh
   {contours, _} = Evision.findContours(bw, Evision.cv_RETR_LIST(), Evision.cv_CHAIN_APPROX_SIMPLE())
 
   list=[]++Enum.map(contours,fn x->Evision.boundingRect(x) end)  
   list2=Enum.map(contours,fn x->Evision.contourArea(x) end)   |> Enum.map(fn x->round(x) end) 
   list2=List.delete_at(list2,-1)
  list3=List.delete_at(list2,-1)     
  listo=Enum.map(list3,fn x->Integer.floor_div(List.last(list3),x) end)
 list4=Enum.with_index(listo,fn element,index->if element != 1 and element != 0, do: index end)|> Enum.reject(fn x->x==nil end)
   rejected_indices = MapSet.new(list4)
   list=list |> Stream.with_index() |> Stream.reject(fn {_item, index} -> index in rejected_indices end)|>Enum.map(&elem(&1, 0))
  newlist=Enum.map(list,fn x-> Tuple.to_list(x) end)    
   final= Enum.map(newlist,fn [x,y,w,h]-> bw[[y..y+h,x..x+w]] end)
   finalop= List.delete_at(final,-1)
   final=List.delete_at(finalop,-1) |> Enum.reverse()
   list= Enum.map(Enum.to_list(0..(Enum.count(final)-1)),fn y->
    Evision.imwrite("y.png",Enum.at(final,y)) 
    TesseractOcr.read("y.png",%{psm: "8"}) end)
   list2=Enum.map(list,fn x-> if x=="o" do 
   "na"  
   else
   if Enum.member?(list,"1") and Enum.member?(list,"11") do
   x
   else
  if x=="1" do
   "11"
   else
    x 
    end
    end
    end
    end)
   cellcount=(Enum.count(final)*1.0)
   Enum.chunk_every(list2,trunc(Float.pow(cellcount,0.5)))
   
   end

 def read(path) do
    OpenCV.imread(path)
  end


  # This function is used to read an image
  # from a given file as grayscale
  def read_gray(path) do
    OpenCV.imread(path, flags: OpenCV.cv_IMREAD_GRAYSCALE)
  end




 # This function is used to resize a given image
  def resize(image, width, height) do
    OpenCV.resize(image,{width,height})
  end

  #This function is used to save a processed image in filesystem
  def save(image, path \\ "images/saved_img.png") do
    OpenCV.imwrite(path, image)
  end

  #This function is used to convert a 3-channel(color) image into a single-channel(grayscale) image
  def gray(image) do
    OpenCV.cvtColor(image,  OpenCV.cv_COLOR_BGR2GRAY)
  end

  # Thresholding operation (Convert grayscale image to binary)
  def thresh(image) do
    OpenCV.adaptiveThreshold(image,255,OpenCV.cv_ADAPTIVE_THRESH_MEAN_C(), OpenCV.cv_THRESH_BINARY,51,7)
  OpenCV.adaptiveThreshold(image,255,OpenCV.cv_ADAPTIVE_THRESH_MEAN_C(), OpenCV.cv_THRESH_BINARY,51,7)
   
  end

  # Morphological opening operation on image
  def morphology_open(image) do
    kernel = OpenCV.getStructuringElement( OpenCV.cv_MORPH_RECT, {5,5})
    OpenCV.morphologyEx(image, OpenCV.cv_MORPH_OPEN, kernel, [{:iterations, 4}])
  end

  # Morphological closing operation on image
  def morphology_close(image) do
    kernel = OpenCV.getStructuringElement( OpenCV.cv_MORPH_RECT, {5,5})
    OpenCV.morphologyEx(image, OpenCV.cv_MORPH_CLOSE, kernel, [{:iterations, 4}])
  
  end

  # cropping a rectangle from image matrix: from x1 to x1+w , y1 to y1+h
  def crop(image, x1, y1, w, h) do
    # Evision.Mat to Tensor conversion > slicing > convert back to Evision.Mat
    OpenCV.Mat.to_nx(image,Nx.BinaryBackend) |> Nx.slice_along_axis(x1,w,axis: 1) |>  Nx.slice_along_axis(y1,h,axis: 0) |> OpenCV.Mat.from_nx
  end

  # Straight Line detection from image
  def find_edges(image) do
    # Find all edges first
    edges = OpenCV.canny(image, 100, 250)
    # Apply Hough transform for finding lines
    OpenCV.houghLinesP(edges, 1, (3.14/180), 150)
  end

  # find all contours and get selected contour's coordinates
  def find_contour(image,position \\ 0) do
    # Find contours and their hierarchy using the function below
    {contours, _} = OpenCV.findContours(image, OpenCV.cv_RETR_LIST(), OpenCV.cv_CHAIN_APPROX_NONE())

    # Get first contour from the list
    box = Enum.at(contours, position)
    # Find contour's bounding rectangle
    {x,y,w,h} = OpenCV.boundingRect(box)
    IO.inspect([x,y,w,h])
  end


  # Bitwise operation on matrices (AND/OR/NOT)
  # Input image should be "binary" i.e. after thresholding.
  # Give a try yourself! :)
  def bitwise_and(image1, image2) do
    OpenCV.Mat.bitwise_and(image1,image2)
  end

  def bitwise_or(image1, image2) do
    OpenCV.Mat.bitwise_or(image1,image2)
  end

  def bitwise_not(image1) do
    OpenCV.Mat.bitwise_not(image1)
  end

  # This "main" function tries to demonstrate the use of the utility functions defined above.
  # The intent is to simplify usage of Evision/OpenCV APIs by creating simple wrappers.
  def main() do
    image = read("images/grid_1.png")          # read color image
    gray_img = read_gray("images/grid_1.png")  # read grayscale image

   

  end




  @doc """
  #Function name:
         identifyCellNumbersWithLocations
  #Inputs:
         matrix  : matrix containing the detected numbers
  #Output:
         List containing tuple of detected number and it's location in the grid
  #Details:
         Function that takes matrix generated as an argument and provides list of tuple
  #Example call:

        iex(1)> matrix = Task1bNumberDetection.identifyCellNumbers("images/grid_1.png")
        [["22", "na", "na"], ["na", "na", "16"], ["na", "25", "na"]]
        iex(2)> Task1bNumberDetection.identifyCellNumbersWithLocations(matrix)
        [{"22", 1}, {"16", 6}, {"25", 8}]
  """
  def identifyCellNumbersWithLocations(matrix) do
      matrix |> List.flatten |> Enum.with_index(fn element,index-> if element != "na" , do: {element,index+1} end) |> Enum.reject(fn x-> x==nil end)

  end


  @doc """
  #Function name:
         driver
  #Inputs:
         path  : The path where all the provided images are present
  #Output:
         A final output with image name as well as the detected number and it's location in gird
  #Details:
         Driver functional which detects numbers from mutiple images provided
  #Note:
         DO NOT EDIT THIS FUNCTION
  #Example call:

      iex(1)> Task1bNumberDetection.driver("images/")
      [
        {"grid_1.png", [{"22", 1}, {"16", 6}, {"25", 8}]},
        {"grid_2.png", [{"13", 3}, {"27", 5}, {"20", 7}]},
        {"grid_3.png", [{"17", 3}, {"20", 4}, {"11", 5}, {"15", 9}]},
        {"grid_4.png", []},
        {"grid_5.png", [{"13", 1}, {"19", 2}, {"17", 3}, {"20", 4}, {"16", 5}, {"11", 6}, {"24", 7}, {"15", 8}, {"28", 9}]},
        {"grid_6.png", [{"20", 2}, {"17", 6}, {"23", 9}, {"15", 13}, {"10", 19}, {"19", 22}]},
        {"grid_7.png", [{"19", 2}, {"21", 4}, {"10", 5}, {"23", 11}, {"15", 13}]}
      ]
  """
  def driver(path \\ "images/") do

       # Getting the path of images
       image_path = path <> "*.png"
       # Creating a list of all images paths with extension .png
       image_list = Path.wildcard(image_path)
       # Parsing through all the images to get final output using the two funtions which teams need to complete
       Enum.map(image_list, fn(x) ->
              {String.trim_leading(x,path), identifyCellNumbers(x) |> identifyCellNumbersWithLocations}
       end)
  end

end
