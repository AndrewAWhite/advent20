#=--- Day 5: Binary Boarding ---

You board your plane only to discover a new problem: you dropped your boarding pass! You aren't sure which seat is yours, 
and all of the flight attendants are busy with the flood of people that suddenly made it through passport control.

You write a quick program to use your phone's camera to scan all of the nearby boarding passes (your puzzle input); 
perhaps you can find your seat through process of elimination.

Instead of zones or groups, this airline uses binary space partitioning to seat people. A seat might be specified like FBFBBFFRLR, 
where F means "front", B means "back", L means "left", and R means "right".

The first 7 characters will either be F or B; these specify exactly one of the 128 rows on the plane (numbered 0 through 127). 
Each letter tells you which half of a region the given seat is in. Start with the whole list of rows; the first letter indicates 
whether the seat is in the front (0 through 63) or the back (64 through 127). The next letter indicates which half of that region 
the seat is in, and so on until you're left with exactly one row.

For example, consider just the first seven characters of FBFBBFFRLR:

    Start by considering the whole range, rows 0 through 127.
    F means to take the lower half, keeping rows 0 through 63.
    B means to take the upper half, keeping rows 32 through 63.
    F means to take the lower half, keeping rows 32 through 47.
    B means to take the upper half, keeping rows 40 through 47.
    B keeps rows 44 through 47.
    F keeps rows 44 through 45.
    The final F keeps the lower of the two, row 44.

The last three characters will be either L or R; these specify exactly one of the 8 columns of seats on the plane (numbered 0 through 7). 
The same process as above proceeds again, this time with only three steps. L means to keep the lower half, while R means to keep the upper half.

For example, consider just the last 3 characters of FBFBBFFRLR:

    Start by considering the whole range, columns 0 through 7.
    R means to take the upper half, keeping columns 4 through 7.
    L means to take the lower half, keeping columns 4 through 5.
    The final R keeps the upper of the two, column 5.

So, decoding FBFBBFFRLR reveals that it is the seat at row 44, column 5.

Every seat also has a unique seat ID: multiply the row by 8, then add the column. In this example, the seat has ID 44 * 8 + 5 = 357.

Here are some other boarding passes:

    BFFFBBFRRR: row 70, column 7, seat ID 567.
    FFFBBBFRRR: row 14, column 7, seat ID 119.
    BBFFBBFRLL: row 102, column 4, seat ID 820.

As a sanity check, look through your list of boarding passes. What is the highest seat ID on a boarding pass?
=#

function parse_seat(seat_spec)
    # take in a seat spec string of form FBFBBFFRLR, return tuple of row, column
    row_part = seat_spec[1:7]
    col_part = seat_spec[8:10]
    row_range = [0, 127]
    col_range = [0, 7]
    for char in row_part
        if char == 'F'
            row_range[2] = row_range[2] - ceil(Int64, (row_range[2] - row_range[1]) / 2)
        elseif char == 'B'
            row_range[1] = row_range[1] + ceil(Int64, (row_range[2] - row_range[1]) / 2)
        end
    end
    for char in col_part
        if char == 'L'
            col_range[2] = col_range[2] - ceil(Int64, (col_range[2] - col_range[1]) / 2)
        elseif char == 'R'
            col_range[1] = col_range[1] + ceil(Int64, (col_range[2] - col_range[1]) / 2)
        end
    end
    return row_range[1], col_range[1]
end

function calculate_id(seat_tuple)
    return (seat_tuple[1] * 8) + seat_tuple[2] 
end


function iter_seat_tuples()
    input = read("../data/input_d5q1.txt", String)
    input_split = split(input, "\n")
    Channel() do channel
        for seat in input_split
            seat_tuple = parse_seat(seat)
            put!(channel, seat_tuple)
        end
    end
end

function q1()
    max_id = 0
    for seat_tuple in iter_seat_tuples()
        id = calculate_id(seat_tuple)
        if id > max_id
            max_id = id
        end
    end
    return max_id
end

#=
--- Part Two ---

Ding! The "fasten seat belt" signs have turned on. Time to find your seat.

It's a completely full flight, so your seat should be the only missing boarding pass in your list. 
However, there's a catch: some of the seats at the very front and back of the plane don't exist on this aircraft, 
so they'll be missing from your list as well.

Your seat wasn't at the very front or back, though; the seats with IDs +1 and -1 from yours will be in your list.

What is the ID of your seat?
=#

function find_seat()
    # find missing seat by sorting full list and finding gap
    seats = sort([s for s in iter_seat_tuples()], by = x -> (x[1], x[2]))
    my_seat = nothing
    # start at second seat, compare to previous seat for full list
    for i in range(2, length=size(seats, 1)-1)
        prev_seat = seats[i-1]
        this_seat = seats[i]
        # if both seats are on the same row, but this seat is more than one column ahead
        # of the previous, then we have found the missing seat
        if prev_seat[1] == this_seat[1] && (this_seat[2] - prev_seat[2]) > 1
            my_seat = (this_seat[1], this_seat[2] - 1)
            break
        # alternatively, if this seat is in the second column, but is the first seen in 
        # the row, then we have found the missing seat
        elseif this_seat[2] == 1 && this_seat[1] > prev_seat[1]
            my_seat = (this_seat[1], 0)
            break
        # finally, if this seat is the first in the row, and the previous wasn't the last
        # in its row, then we have found the missing seat
        elseif this_seat[1] == 0 && prev_seat[2] != 7
            my_seat = (prev_seat[1], 7)
        end
    end
    return my_seat
end

function q2()
    seat = find_seat()
    id = calculate_id(seat)
    return id
end