#=
--- Day 14: Docking Data ---

As your ferry approaches the sea port, the captain asks for your help again. The computer system that runs this port isn't compatible with the docking program on the ferry, 
so the docking parameters aren't being correctly initialized in the docking program's memory.

After a brief inspection, you discover that the sea port's computer system uses a strange bitmask system in its initialization program. Although you don't have the correct 
decoder chip handy, you can emulate it in software!

The initialization program (your puzzle input) can either update the bitmask or write a value to memory. Values and memory addresses are both 36-bit unsigned integers. 
For example, ignoring bitmasks for a moment, a line like mem[8] = 11 would write the value 11 to memory address 8.

The bitmask is always given as a string of 36 bits, written with the most significant bit (representing 2^35) on the left and the least significant bit (2^0, that is, the 1s bit) 
on the right. The current bitmask is applied to values immediately before they are written to memory: a 0 or 1 overwrites the corresponding bit in the value, while an X leaves 
the bit in the value unchanged.

For example, consider the following program:

mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
mem[8] = 11
mem[7] = 101
mem[8] = 0

This program starts by specifying a bitmask (mask = ....). The mask it specifies will overwrite two bits in every written value: the 2s bit is overwritten with 0, and the 64s 
bit is overwritten with 1.

The program then attempts to write the value 11 to memory address 8. By expanding everything out to individual bits, the mask is applied as follows:

value:  000000000000000000000000000000001011  (decimal 11)
mask:   XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
result: 000000000000000000000000000001001001  (decimal 73)

So, because of the mask, the value 73 is written to memory address 8 instead. Then, the program tries to write 101 to address 7:

value:  000000000000000000000000000001100101  (decimal 101)
mask:   XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
result: 000000000000000000000000000001100101  (decimal 101)

This time, the mask has no effect, as the bits it overwrote were already the values the mask tried to set. Finally, the program tries to write 0 to address 8:

value:  000000000000000000000000000000000000  (decimal 0)
mask:   XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
result: 000000000000000000000000000001000000  (decimal 64)

64 is written to address 8 instead, overwriting the value that was there previously.

To initialize your ferry's docking program, you need the sum of all values left in memory after the initialization program completes. (The entire 36-bit address space begins initialized 
to the value 0 at every address.) In the above example, only two values in memory are not zero - 101 (at address 7) and 64 (at address 8) - producing a sum of 165.

Execute the initialization program. What is the sum of all values left in memory after it completes?
=#

function read_input_q1()
    instructions = readlines("data/input_d14q1.txt") .|> x -> split(x, " = ")
    instructions = map(x -> begin
        if x[1] == "mask"
            return ("mask", nothing, x[2])
        end
        addr = match(r"(?<=\[)[0-9]+(?=\])", x[1]).match
        val = x[2]
        return ("mem", parse(Int64, addr), parse(Int64, val))
    end, instructions)
    return instructions
end

function convert_mask_q1(mask)
    m1 = BitArray(map(x -> x=='1' ? 1 : 0, collect(mask)))
    m2 = BitArray(map(x -> x=='0' ? 1 : 0, collect(mask)))
    return (m1, m2)
end

function to_bits(value)
    return digits(value, base=2, pad=36) |> reverse |> BitArray
end

function apply_mask_q1(value, mask)
    val = to_bits(value)
    masks = convert_mask_q1(mask)
    val = zip(val, masks[1]) .|> xy -> xy[2]==1 ? 1 : xy[1]
    val = zip(val, masks[2]) .|> xy -> xy[2]==1 ? 0 : xy[1]
    return sum(val |> reverse |> enumerate .|> ix -> ix[2] << (ix[1] -1))
end

function q1()
    instructions = read_input_q1()
    mem = Dict()
    mask = nothing
    for instruction in instructions
        println(instruction)
        if instruction[1] == "mask"
            mask = instruction[3]
            continue
        end
        mem[instruction[2]] = apply_mask_q1(instruction[3], mask)
    end
    return sum(values(mem))
end

#=
--- Part Two ---

For some reason, the sea port's computer system still can't communicate with your ferry's docking program. It must be using version 2 of the decoder chip!

A version 2 decoder chip doesn't modify the values being written at all. Instead, it acts as a memory address decoder. Immediately before a value is written 
to memory, each bit in the bitmask modifies the corresponding bit of the destination memory address in the following way:

    If the bitmask bit is 0, the corresponding memory address bit is unchanged.
    If the bitmask bit is 1, the corresponding memory address bit is overwritten with 1.
    If the bitmask bit is X, the corresponding memory address bit is floating.

A floating bit is not connected to anything and instead fluctuates unpredictably. In practice, this means the floating bits will take on all possible values, 
potentially causing many memory addresses to be written all at once!

For example, consider the following program:

mask = 000000000000000000000000000000X1001X
mem[42] = 100
mask = 00000000000000000000000000000000X0XX
mem[26] = 1

When this program goes to write to memory address 42, it first applies the bitmask:

address: 000000000000000000000000000000101010  (decimal 42)
mask:    000000000000000000000000000000X1001X
result:  000000000000000000000000000000X1101X

After applying the mask, four bits are overwritten, three of which are different, and two of which are floating. Floating bits take on every possible combination 
of values; with two floating bits, four actual memory addresses are written:

000000000000000000000000000000011010  (decimal 26)
000000000000000000000000000000011011  (decimal 27)
000000000000000000000000000000111010  (decimal 58)
000000000000000000000000000000111011  (decimal 59)

Next, the program is about to write to memory address 26 with a different bitmask:

address: 000000000000000000000000000000011010  (decimal 26)
mask:    00000000000000000000000000000000X0XX
result:  00000000000000000000000000000001X0XX

This results in an address with three floating bits, causing writes to eight memory addresses:

000000000000000000000000000000010000  (decimal 16)
000000000000000000000000000000010001  (decimal 17)
000000000000000000000000000000010010  (decimal 18)
000000000000000000000000000000010011  (decimal 19)
000000000000000000000000000000011000  (decimal 24)
000000000000000000000000000000011001  (decimal 25)
000000000000000000000000000000011010  (decimal 26)
000000000000000000000000000000011011  (decimal 27)

The entire 36-bit address space still begins initialized to the value 0 at every address, and you still need the sum of all values left in memory at the end of 
the program. In this example, the sum is 208.

Execute the initialization program using an emulator for a version 2 decoder chip. What is the sum of all values left in memory after it completes?
=#


function apply_mask_q2(addr, mask)
    addr = to_bits(addr)
    mem_spec = zip(addr, mask) .|> 
        xy -> begin
            if xy[2] == '1'
                return 1
            elseif xy[2] == '0'
                if xy[1]
                    return 1
                else
                    return 0
                end
            elseif xy[2] == 'X'
                return 2
            end
        end
    return mem_spec
end

function get_overlap(spec_1, spec_2)
    overlap = []
    for xy in zip(spec_1, spec_2) 
        if xy[1] == 0
            if xy[2] == 1
                return nothing
            end
            push!(overlap, 0)
        elseif xy[1] == 1
            if xy[2] == 0
                return nothing
            end
            push!(overlap, 1)
        elseif xy[1] == 2
            if xy[2] == 2
                push!(overlap, 2)
            else
                push!(overlap, xy[2])
            end
        end
    end
    return overlap
end

function q2()
    mem_specs = []
    vals = []
    mask = nothing
    # represent memory address ranges as "specs"
    # where 0, 1 represent themselves, and 2 represents superposition
    for instruction in read_input_q1()
        if instruction[1] == "mask"
            mask = instruction[3]
            continue
        end
        mem_spec = apply_mask_q2(instruction[2], mask)
        push!(mem_specs, mem_spec)
        push!(vals, instruction[3])
    end
    # reverse ranges and values to assign to ranges
    # so that later assignments overwrite earlier ones
    reverse!(mem_specs)
    reverse!(vals)
    addr_overlaps = Dict()
    ## messy part
    # loop through address ranges, building up a record
    # of previously assigned ranges that overlap, 
    # along with how many addresses in the space overlap
    result = 0
    for (i, spec_1) in enumerate(mem_specs)
        # dictionary of spec -> number of conflicting addresses
        these_overlaps = get(addr_overlaps, i, nothing)
        # if there are no overlapping specs already assigned,
        # subtract 0
        discount = 0
        if !isnothing(these_overlaps)
            # otherwise, subtract the number of ranges that have
            # already been written
            discount = sum(values(these_overlaps))
        end
        value = vals[i]
        # the number of addresses that will contain this value
        # is = to 2^ of the number of Xs in the spec, minus those
        # addresses that have already been written
        mult = (2 ^ count(x -> x==2, spec_1)) - discount
        result += value * mult
        # find the overlapping addresses for subsequent specs
        for (j, spec_2) in enumerate(mem_specs[i+1:end])
            overlaps = get(addr_overlaps, i+j, Dict())
            overlap = get_overlap(spec_1, spec_2)
            # if they do not conflict, continue
            if isnothing(overlap)
                continue
            end
            # otherwise, for any already existing spec
            # we have to subtract the number of shared addresses between
            # the existing spec and this spec
            key = join(overlap)
            if !(key in keys(overlaps))
                ov = (2 ^ count(x->x=='2', key))
                for ek in keys(overlaps)
                    # nasty bit of work to go back from string key -> mask, and get overlap
                    ekov = get_overlap(map(x->parse(Int64, x), collect(key)),map(x->parse(Int64, x), collect(ek)))
                    if !isnothing(ekov)
                        # if there is an overlap, we subtract the number of addresses
                        # that were already written
                        ov -= (2 ^ count(x->x==2, ekov))
                    end
                end
                overlaps[key] = ov
                addr_overlaps[i+j] = overlaps
            end
        end
    end
    return result
end

@time q2()