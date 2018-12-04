defmodule Do do

# Эта функция выполняет все функции подряд
  def go do
    get_name
    |> gen_hash
    |> find_rgb
    |> do_grid
    |> filter
    |> squares
    |>IO.inspect(label: "before image")
    |> image
    |>IO.inspect(label: "after image")
    |> save
  end

# Эта функция просит ввести слово и отрезает лишнее
  def get_name() do
    input = IO.gets" Введи имя - "
    name = String.trim(input)
  end
# Эта функция генерит из слова хеш и сохраняет в структуру слово и его хеш
  def gen_hash(name) do
    hex = :crypto.hash(:md5, name ) |> :binary.bin_to_list
      %Do.Str{name: name, hex: hex}
  end
# Эта функция берет первые три элемента хеша из структуры за данные для RGB и
# сохраняет в структуру
  def find_rgb(color) do
    %Do.Str{hex: [r, g, b| _tail]} = color
      %Do.Str{color | color: {r, g, b}}
  end
# эта функция берет значене хеша из структуры и делает сетку,
# сохраняет в структуру
  def do_grid(%Do.Str{hex: hex} = image) do
    grid = hex |> Enum.chunk(3) |> Enum.map(&mirror/1) |> List.flatten |> Enum.with_index
      %Do.Str{image | grid: grid}
  end
  # Эта функция зеркалит сетку
  def mirror(raw) do
    [a, b | _tail] = raw
    raw ++ [b, a]
  end
# Эта функция фильтрует элементы сетки, которые покрасим, сохраняет в структуру
  def filter(%Do.Str{grid: grid} = image) do
    gridcolor = Enum.filter grid, fn({num, _index}) ->
      rem(num, 2) == 0
    end
    %Do.Str{image | gridcolor: gridcolor}
  end
# Эта функция задает координаты сетки для покраски - сохраняет вструктуру
  def squares(%Do.Str{gridcolor: gridcolor} = image) do
    mapcolor = Enum.map gridcolor, fn({_num, ind}) ->
      x1 = rem(ind, 5) * 50
      y1 = div(ind, 5) * 50
      topleft = {x1, y1}
      bottomright = {x1+50, y1+50}

      {topleft, bottomright}
    end
    %Do.Str{image | mapcolor: mapcolor}
  end
# Эта функция рисует
  def image(%Do.Str{color: color, mapcolor: mapcolor} = struct) do
    blank = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each mapcolor, fn({start, stop}) ->
      :egd.filledRectangle(blank, start, stop, fill)
    end
    img = :egd.render(blank)
    %Do.Str{struct | image: img}
  end
# Эта функция должна сохранять!
# За аргументы я беру значение из прошлой функции и переменную name,
# ее я определил в начале
  def save(%Do.Str{name: name, image: img}) do
    File.write("#{name}.png", img)
  end
end
#
