#=
--- Day 1: Report Repair ---

After saving Christmas five years in a row, you've decided to take a vacation at a nice resort on a tropical island. Surely, Christmas will go on without you.

The tropical island has its own currency and is entirely cash-only. The gold coins used there have a little picture of a starfish; the locals just call them stars. 
None of the currency exchanges seem to have heard of them, but somehow, you'll need to find fifty of these coins by the time you arrive so you can pay the deposit on your room.

To save your vacation, you need to get all fifty stars by December 25th.

Collect stars by solving puzzles. Two puzzles will be made available on each day in the Advent calendar; 
the second puzzle is unlocked when you complete the first. Each puzzle grants one star. Good luck!

Before you leave, the Elves in accounting just need you to fix your expense report (your puzzle input); apparently, something isn't quite adding up.

Specifically, they need you to find the two entries that sum to 2020 and then multiply those two numbers together.

For example, suppose your expense report contained the following:

1721
979
366
299
675
1456

In this list, the two entries that sum to 2020 are 1721 and 299. Multiplying them together produces 1721 * 299 = 514579, so the correct answer is 514579.

Of course, your expense report is much larger. Find the two entries that sum to 2020; what do you get if you multiply them together?
=#

using DelimitedFiles
using IterTools

function find_2_factors(source_list)
   for i in range(1, length=size(source_list, 1))
        val_i = source_list[i]
        for j in range(i+1, length=size(source_list, 1)-i)
            println([i, j])
            val_j = source_list[j]
            if val_i + val_j == 2020
                return val_i, val_j
            end
        end
   end
end

function q1()
    source_list = vec(readdlm("../data/input_d1q1.txt", Int64))
    factors = find_2_factors(source_list)
    return factors[1] * factors[2] 
end

#=
--- Part Two ---

The Elves in accounting are thankful for your help; one of them even offers you a starfish coin they had left over from a past vacation. 
They offer you a second one if you can find three numbers in your expense report that meet the same criteria.

Using the above example again, the three entries that sum to 2020 are 979, 366, and 675. Multiplying them together produces the answer, 241861950.

In your expense report, what is the product of the three entries that sum to 2020?
=#

function find_3_factors(source_list)
    for i in range(1, length=size(source_list, 1))
         val_i = source_list[i]
         for j in range(i+1, length=size(source_list, 1)-i)
            val_j = source_list[j]
            for k in range(j+1, length=size(source_list, 1)-j)
                val_k = source_list[k]
                if val_i + val_j + val_k == 2020
                    return val_i, val_j, val_k
                end
            end
         end
    end
 end

function q2()
    source_list = vec(readdlm("../data/input_d1q1.txt", Int64))
    factors = find_3_factors(source_list)
    return factors[1] * factors[2]  * factors[3]
end

#=
--- Bonus ---
Try to implement a generic solution for finding the factors given an arbitary number of entries
=#

function find_n_factors(source_list, n)
    source_size = size(source_list, 1)
    index_list = Vector{Int64}(undef, source_size)
    for i in range(1, length=source_size)
        index_list[i] = i
    end
    # iterate over all possible masks of size n
    for mask in subsets(index_list, n)
        sum = 0
        for idx in mask
            sum = sum + source_list[idx]
        end
        if sum == 2020
            factors = Vector{Int64}(undef, n)
            for i in range(1, length=n)
                factors[i] = source_list[mask[i]]
            end
            return factors
        end
    end
end

println(find_n_factors(vec(readdlm("../data/input_d1q1.txt", Int64)), 3))