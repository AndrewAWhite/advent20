#=--- Day 20: Jurassic Jigsaw ---

The high-speed train leaves the forest and quickly carries you south. You can even see a desert in the distance! Since you have some spare time, 
you might as well see if there was anything interesting in the image the Mythical Information Bureau satellite captured.

After decoding the satellite messages, you discover that the data actually contains many small images created by the satellite's camera array. 
The camera array consists of many cameras; rather than produce a single square image, they produce many smaller square image tiles that need to 
be reassembled back into a single image.

Each camera in the camera array returns a single monochrome image tile with a random unique ID number. The tiles (your puzzle input) arrived in 
a random order.

Worse yet, the camera array appears to be malfunctioning: each image tile has been rotated and flipped to a random orientation. Your first task 
is to reassemble the original image by orienting the tiles so they fit together.

To show how the tiles should be reassembled, each tile's image data includes a border that should line up exactly with its adjacent tiles. All 
tiles have this border, and the border lines up exactly when the tiles are both oriented correctly. Tiles at the edge of the image also have 
this border, but the outermost edges won't line up with any other tiles.

For example, suppose you have the following nine tiles:

Tile 2311:
..##.#..#.
##..#.....
#...##..#.
####.#...#
##.##.###.
##...#.###
.#.#.#..##
..#....#..
###...#.#.
..###..###

Tile 1951:
#.##...##.
#.####...#
.....#..##
#...######
.##.#....#
.###.#####
###.##.##.
.###....#.
..#.#..#.#
#...##.#..

Tile 1171:
####...##.
#..##.#..#
##.#..#.#.
.###.####.
..###.####
.##....##.
.#...####.
#.##.####.
####..#...
.....##...

Tile 1427:
###.##.#..
.#..#.##..
.#.##.#..#
#.#.#.##.#
....#...##
...##..##.
...#.#####
.#.####.#.
..#..###.#
..##.#..#.

Tile 1489:
##.#.#....
..##...#..
.##..##...
..#...#...
#####...#.
#..#.#.#.#
...#.#.#..
##.#...##.
..##.##.##
###.##.#..

Tile 2473:
#....####.
#..#.##...
#.##..#...
######.#.#
.#...#.#.#
.#########
.###.#..#.
########.#
##...##.#.
..###.#.#.

Tile 2971:
..#.#....#
#...###...
#.#.###...
##.##..#..
.#####..##
.#..####.#
#..#.#..#.
..####.###
..#.#.###.
...#.#.#.#

Tile 2729:
...#.#.#.#
####.#....
..#.#.....
....#..#.#
.##..##.#.
.#.####...
####.#.#..
##.####...
##..#.##..
#.##...##.

Tile 3079:
#.#.#####.
.#..######
..#.......
######....
####.#..#.
.#...#.##.
#.#####.##
..#.###...
..#.......
..#.###...

By rotating, flipping, and rearranging them, you can find a square arrangement that causes all adjacent borders to line up:

#...##.#.. ..###..### #.#.#####.
..#.#..#.# ###...#.#. .#..######
.###....#. ..#....#.. ..#.......
###.##.##. .#.#.#..## ######....
.###.##### ##...#.### ####.#..#.
.##.#....# ##.##.###. .#...#.##.
#...###### ####.#...# #.#####.##
.....#..## #...##..#. ..#.###...
#.####...# ##..#..... ..#.......
#.##...##. ..##.#..#. ..#.###...

#.##...##. ..##.#..#. ..#.###...
##..#.##.. ..#..###.# ##.##....#
##.####... .#.####.#. ..#.###..#
####.#.#.. ...#.##### ###.#..###
.#.####... ...##..##. .######.##
.##..##.#. ....#...## #.#.#.#...
....#..#.# #.#.#.##.# #.###.###.
..#.#..... .#.##.#..# #.###.##..
####.#.... .#..#.##.. .######...
...#.#.#.# ###.##.#.. .##...####

...#.#.#.# ###.##.#.. .##...####
..#.#.###. ..##.##.## #..#.##..#
..####.### ##.#...##. .#.#..#.##
#..#.#..#. ...#.#.#.. .####.###.
.#..####.# #..#.#.#.# ####.###..
.#####..## #####...#. .##....##.
##.##..#.. ..#...#... .####...#.
#.#.###... .##..##... .####.##.#
#...###... ..##...#.. ...#..####
..#.#....# ##.#.#.... ...##.....

For reference, the IDs of the above tiles are:

1951    2311    3079
2729    1427    2473
2971    1489    1171

To check that you've assembled the image correctly, multiply the IDs of the four corner tiles together. If you do this with the 
assembled tiles from the example above, you get 1951 * 3079 * 2971 * 1171 = 20899048083289.

Assemble the tiles into an image. What do you get if you multiply together the IDs of the four corner tiles?
=#

function tilenametonum(t)
    return parse(Int64, match(r"[0-9]+", t[1]).match)
end

function tilestoedges(rows)
    # take in an array of .#.#.# strings, representing a row within
    # a puzzle tile, return 2 lists with integer ids representing each
    # edge
    leftside = join(map(r->r[1], rows))
    topside = rows[1]
    rightside = join(map(r->r[end], rows))
    bottomside = rows[end]
    topnums =
    sides = [[], []]
    for side in [leftside, topside, rightside, bottomside]
        sidebits = collect(c=='#' ? 1 : 0 for c in side)
        push!(sides[1], sum(ti-> ti[2] == 1 ? 2^(ti[1]-1) : 0, enumerate(sidebits)))
        push!(sides[2], sum(ti-> ti[2] == 1 ? 2^(ti[1]-1) : 0, enumerate(reverse(sidebits))))
    end
    return sides
end

function get_tiles()
    # read input, return dict of tile id -> tile representation
    # each tile is represented as a collection of two 4 element arrays of integers
    # where each integer corresponds to an orientation of .#.## characters interpreted as a binary digit
    # with the 2 lists representing each side being oriented left -> right (or top->down), or their inverse. 
    input = read("data/input_d20q1.txt", String)
    tiles_raw = split(input, "\n\n")
    tiles_split = map(t->split(t, "\n"), tiles_raw)
    tiles = Dict(tilenametonum(t)=>tilestoedges(t[2:end]) for t in tiles_split)
    return tiles
end

function get_edge_to_id(tiles)
    # take in the tile id -> representation dict,
    # return a dict of edge id -> set of tile ids that possess edge
    edge_to_id = Dict()
    for (id, edges) in tiles
        for e in edges[1]
            ids = get(edge_to_id, e, Set())
            push!(ids, id)
            edge_to_id[e] = ids
        end
        for e in edges[2]
            ids = get(edge_to_id, e, Set())
            push!(ids, id)
            edge_to_id[e] = ids
        end
    end
    return edge_to_id
end

function q1()
    # find corner pieces by determining which tiles possess
    # 2 edges that are unique in either orientation
    # any such tile must be a corner piece
    tiles = get_tiles()
    edge_to_id = get_edge_to_id(tiles)
    corners = Set()
    for (id, tiles) in tiles
        unique_edge_count = 0
        for pos in 1:4
            if length(edge_to_id[tiles[1][pos]]) == 1 && length(edge_to_id[tiles[2][pos]]) == 1
                unique_edge_count += 1
            end
            if unique_edge_count > 1
                push!(corners, id)
            end
        end
    end
    result = 1
    for id in corners
        result *= id
    end
    return result
end

