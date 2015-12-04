#
# useful agregate
#

# function count
# {
#     BEGIN { $x = 0 }
#     PROCESS { $x += 1 }
#     END { $x }
# }

# function product
# {
#     BEGIN { $x = 1 }
#     PROCESS { $x *= $_ }
#     END { $x }
# }

# function sum
# {
#     BEGIN { $x = 0 }
#     PROCESS { $x += $_ }
#     END { $x }
# }

# function average
# {
#     BEGIN { $max = 0; $curr = 0 }
#     PROCESS { $max += $_; $curr += 1 }
#     END { $max / $curr }
# }

#
# Covnersion
#

function ConvertTo-Hex([long] $dec) 
{
   return "0x" + $dec.ToString("X")
}
