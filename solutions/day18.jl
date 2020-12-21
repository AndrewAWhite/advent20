#=
--- Day 18: Operation Order ---

As you look out the window and notice a heavily-forested continent slowly appear over the horizon, you are interrupted by the child sitting next to you. 
They're curious if you could help them with their math homework.

Unfortunately, it seems like this "math" follows different rules than you remember.

The homework (your puzzle input) consists of a series of expressions that consist of addition (+), multiplication (*), and parentheses ((...)). Just like 
normal math, parentheses indicate that the expression inside must be evaluated before it can be used by the surrounding expression. Addition still finds 
the sum of the numbers on both sides of the operator, and multiplication still finds the product.

However, the rules of operator precedence have changed. Rather than evaluating multiplication before addition, the operators have the same precedence, 
and are evaluated left-to-right regardless of the order in which they appear.

For example, the steps to evaluate the expression 1 + 2 * 3 + 4 * 5 + 6 are as follows:

1 + 2 * 3 + 4 * 5 + 6
  3   * 3 + 4 * 5 + 6
      9   + 4 * 5 + 6
         13   * 5 + 6
             65   + 6
                 71

Parentheses can override this order; for example, here is what happens if parentheses are added to form 1 + (2 * 3) + (4 * (5 + 6)):

1 + (2 * 3) + (4 * (5 + 6))
1 +    6    + (4 * (5 + 6))
     7      + (4 * (5 + 6))
     7      + (4 *   11   )
     7      +     44
            51

Here are a few more examples:

    2 * 3 + (4 * 5) becomes 26.
    5 + (8 * 3 + 9 + 3 * 4 * 3) becomes 437.
    5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4)) becomes 12240.
    ((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2 becomes 13632.

Before you can help with the homework, you need to understand it yourself. Evaluate the expression on each line of the homework; 
what is the sum of the resulting values?
=#


function parseparenthesis(expr)
    # takes in an array of characters representing an expression,
    # returns array of containing sub-arrays containing either integers or op characters 
    # with nesting representing parenthesis 
    # e.g. "1 + (2 + (4 + 5)) + 6" -> [1, '+', [2, '+', [4, '+', 5]] '+', 6]
    bcount = 0
    capture = false
    a = []
    newexpr = []
    sp = ['(', ')', '*', '+', '-']
    for char in expr
        if char == '('
            bcount += 1
            if capture == false
                capture = true
                a = []
                continue
            end
        elseif char == ')'
            bcount -= 1
        end
        if typeof(char) == Char && !(char in sp)
            char = parse(Int64, char)
        end
        if capture
            if bcount == 0
                push!(newexpr, parseparenthesis(a))
                a = []
                capture = false
            else
                push!(a, char)
            end
        else
            push!(newexpr, char)
        end
    end
    return newexpr
end

function reduceexpr(expr)
    # take in array of ints + op characters,
    # return result of computation using left -> right precedence,
    # respecting parenthesis
    ops = ['*', '+', '-']
    op = nothing
    s = []
    for exp in expr
        if isnothing(exp) continue end
        if length(exp) > 1
            exp = reduceexpr(exp)
        end
        if exp in ops
            op = exp
            continue
        end
        push!(s, exp)
        if !isnothing(op) && length(s) == 2
            l = nothing
            if length(s[1]) == 1
                l = s[1]
            else
                l = reduceexpr(s[1])
            end
            r = nothing
            if length(s[2]) == 1
                r = s[2]
            else
                r = reduceexpr(s[2])
            end
            if op == '*'
                s = [l * r]
            elseif op == '+'
                s =  [l + r]
            elseif op == '-'
                s = [l - r]
            end
            op = nothing
        end
    end
    return s[1]
end 

function evaluate_q1(input)
    input = collect(replace(input, r" "=>""))
    expr = parseparenthesis(input)
    r = reduceexpr(expr)
    return r
end

function q1()
    sum = 0
    for line in readlines("data/input_d18q1.txt")
        sum += evaluate_q1(line)
    end
    return sum
end

#=
--- Part Two ---

You manage to answer the child's questions and they finish part 1 of their homework, but get stuck when they reach the next section: advanced math.

Now, addition and multiplication have different precedence levels, but they're not the ones you're familiar with. Instead, addition is evaluated before multiplication.

For example, the steps to evaluate the expression 1 + 2 * 3 + 4 * 5 + 6 are now as follows:

1 + 2 * 3 + 4 * 5 + 6
  3   * 3 + 4 * 5 + 6
  3   *   7   * 5 + 6
  3   *   7   *  11
     21       *  11
         231

Here are the other examples from above:

    1 + (2 * 3) + (4 * (5 + 6)) still becomes 51.
    2 * 3 + (4 * 5) becomes 46.
    5 + (8 * 3 + 9 + 3 * 4 * 3) becomes 1445.
    5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4)) becomes 669060.
    ((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2 becomes 23340.

What do you get if you add up the results of evaluating the homework problems using these new rules?
=#


function encaseadd(expr)
    # takes in array of same form as result of parseparenthesis
    # returns array with add operations encapsulated in sub expressions
    # e.g. [1, '+', 3, '*', 5] -> [[1, '+', 3], '*', 5] 
    a = []
    if isnothing(expr) || length(expr) == 1
        return expr
    end
    for (i, sexpr) in enumerate(expr)
        if isnothing(sexpr) continue end
        if length(sexpr) > 1
            sexpr = encaseadd(sexpr)
        end
        if sexpr == '+'
            expr[i-1] = [encaseadd(expr[i-1]), '+', encaseadd(expr[i+1])]
            expr[i] = nothing
            expr[i+1] = nothing
            j = i+2
            while j < length(expr) && expr[j] == '+'
                push!(expr[i-1], '+')
                push!(expr[i-1], encaseadd(expr[j+1]))
                expr[j] = nothing
                expr[j+1] = nothing
                j += 2
            end
        end
    end
    return expr
end

function evaluate_q2(input)
    input = collect(replace(input, r" "=>""))
    expr = parseparenthesis(input)
    expr = encaseadd(expr)
    r = reduceexpr(expr)
    return r
end

function q2()
    sum = 0
    for line in readlines("data/input_d18q1.txt")
        sum += evaluate_q2(line)
    end
    return sum
end


@time q2()