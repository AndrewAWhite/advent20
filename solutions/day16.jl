#=
--- Day 16: Ticket Translation ---

As you're walking to yet another connecting flight, you realize that one of the legs of your re-routed trip coming up is on a high-speed train.
However, the train ticket you were given is in a language you don't understand. You should probably figure out what it says before you get to 
the train station after the next flight.

Unfortunately, you can't actually read the words on the ticket. You can, however, read the numbers, and so you figure out the fields these 
tickets must have and the valid ranges for values in those fields.

You collect the rules for ticket fields, the numbers on your ticket, and the numbers on other nearby tickets for the same train service (via 
the airport security cameras) together into a single document you can reference (your puzzle input).

The rules for ticket fields specify a list of fields that exist somewhere on the ticket and the valid ranges of values for each field. For 
example, a rule like class: 1-3 or 5-7 means that one of the fields in every ticket is named class and can be any value in the ranges 1-3 
or 5-7 (inclusive, such that 3 and 5 are both valid in this field, but 4 is not).

Each ticket is represented by a single line of comma-separated values. The values are the numbers on the ticket in the order they appear; every 
ticket has the same format. For example, consider this ticket:

.--------------------------------------------------------.
| ????: 101    ?????: 102   ??????????: 103     ???: 104 |
|                                                        |
| ??: 301  ??: 302             ???????: 303      ??????? |
| ??: 401  ??: 402           ???? ????: 403    ????????? |
'--------------------------------------------------------'

Here, ? represents text in a language you don't understand. This ticket might be represented as 101,102,103,104,301,302,303,401,402,403; of course, 
the actual train tickets you're looking at are much more complicated. In any case, you've extracted just the numbers in such a way that the first 
number is always the same specific field, the second number is always a different specific field, and so on - you just don't know what each position
actually means!

Start by determining which tickets are completely invalid; these are tickets that contain values which aren't valid for any field. Ignore your ticket 
for now.

For example, suppose you have the following notes:

class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12

It doesn't matter which position corresponds to which field; you can identify invalid nearby tickets by considering only whether tickets contain values 
that are not valid for any field. In this example, the values on the first nearby ticket are all valid for at least one field. This is not true of the 
other three nearby tickets: the values 4, 55, and 12 are are not valid for any field. Adding together all of the invalid values produces your ticket 
scanning error rate: 4 + 55 + 12 = 71.

Consider the validity of the nearby tickets you scanned. What is your ticket scanning error rate?
=#

function read_rules()
    rules = []
    for line in readlines("data/input_d16q1.txt")
        if line == ""
            break
        end
        sp = split(line, ": ")
        name = sp[1]
        rsp = split(sp[2], " or ")
        r1 = split(rsp[1], "-")
        r2 = split(rsp[2], "-")
        push!(rules, [[parse(Int64, r1[1]), parse(Int64, r1[2])], [parse(Int64, r2[1]), parse(Int64, r2[2])]])
    end
    return rules
end

function read_rule_names()
    names = []
    for line in readlines("data/input_d16q1.txt")
        if line == ""
            break
        end
        sp = split(line, ": ")
        name = sp[1]
        push!(names, name)
    end
    return names
end

function read_ticket()
    lines = read("data/input_d16q1.txt", String)
    line = match(r"(?<=your ticket\:\n).+(?=\n)", lines).match
    line = split(line, ",") .|> x -> parse(Int64, x)
    return line
end

function read_other_tickets()
    lines = readlines("data/input_d16q1.txt")
    rec = false
    tickets = []
    for line in lines
        if line == "nearby tickets:"
            rec = true
            continue
        end
        if !rec 
            continue 
        end
        ticket = collect(split(line, ",") .|> x -> parse(Int64, x))
        push!(tickets, ticket)
    end
    return tickets
end

function q1()
    tickets = read_other_tickets()
    rules = read_rules()
    invalid_fields = []
    for ticket in tickets
        for f in ticket
            if all(r -> !((r[1][1] <= f <= r[1][2]) || (r[2][1] <= f <= r[2][2])), rules)
                push!(invalid_fields, f)
            end
        end
    end
    return sum(invalid_fields)
end


#=
--- Part Two ---

Now that you've identified which tickets contain invalid values, discard those tickets entirely. Use the remaining valid tickets to determine 
which field is which.

Using the valid ranges for each field, determine what order the fields appear on the tickets. The order is consistent between all tickets: 
if seat is the third field, it is the third field on every ticket, including your ticket.

For example, suppose you have the following notes:

class: 0-1 or 4-19
row: 0-5 or 8-19
seat: 0-13 or 16-19

your ticket:
11,12,13

nearby tickets:
3,9,18
15,1,5
5,14,9

Based on the nearby tickets in the above example, the first position must be row, the second position must be class, and the third position 
must be seat; you can conclude that in your ticket, class is 12, row is 11, and seat is 13.

Once you work out which field is which, look for the six fields on your ticket that start with the word departure. What do you get if you 
multiply those six values together?
=#

function get_valid_tickets()
    tickets = read_other_tickets()
    rules = read_rules()
    valid_tickets = []
    for ticket in tickets
        valid = true
        for f in ticket
            if all(r -> !((r[1][1] <= f <= r[1][2]) || (r[2][1] <= f <= r[2][2])), rules)
                valid = false
                continue
            end
        end
        if !valid continue end
        push!(valid_tickets, ticket)
    end
    return valid_tickets
end

function q2()
    valid_tickets = get_valid_tickets()
    rules = read_rules()
    possible_rules = [Set() for i in 1:length(valid_tickets[1])]
    # determine possible rules
    for ticket in valid_tickets
        for (i, f) in enumerate(ticket)
            for (j, r) in enumerate(rules)
                if (r[1][1] <= f <= r[1][2] || r[2][1] <= f <= r[2][2])
                    push!(possible_rules[i], j)
                end
            end
        end
    end
    # clear impossible
    for ticket in valid_tickets
        for (i, f) in enumerate(ticket)
            for rj in possible_rules[i]
                r = rules[rj]
                if !(r[1][1] <= f <= r[1][2] || r[2][1] <= f <= r[2][2])
                    delete!(possible_rules[i], rj)
                end
            end
        end
    end
    # assign rules to positions
    sorted_rules = sort(collect(enumerate(possible_rules)), by=ix->length(ix[2]))
    placed_rules = [0 for i in 1:length(valid_tickets[1])]
    for (i, rules) in sorted_rules
        for r in rules
            if !(r in placed_rules)
                placed_rules[i] = r
            end
        end
    end
    # pick out position of fields starting with "departure"
    chosen_places = []
    for (i, x) in enumerate(read_rule_names())
        if startswith(x, "departure")
            push!(chosen_places, findfirst(r->r==i, placed_rules))
        end
    end
    # generate answer
    ticket = read_ticket()
    res = 1
    for i in chosen_places
        res *= ticket[i]
    end
    return res
end

println(q2())