module CSV

using Mmap

const BYTES = fill(false, 128)
BYTES[Int(',')] = true
BYTES[Int('\n')] = true
BYTES[Int('\r')] = true
const MASKS = [
    0b00000001,
    0b00000010,
    0b00000100,
    0b00001000,
    0b00010000,
    0b00100000,
    0b01000000,
    0b10000000,
]
const COMMA = UInt8(',')
const NEWLINE = UInt8('\n')
const RETURN = UInt8('\r')

function parse(file="/home/chronos/user/Downloads/.julia/v0.7/CSV/test/test_files/Fielding.csv")
    m = Mmap.mmap(file)
    bitmap = zeros(UInt8, fld1(length(m), 8))
    i = 1
    j = 1
    len = length(m)
    @inbounds for i = 1:8:len
        b = m[i]
        mask = ifelse(b == COMMA || b == NEWLINE || b == RETURN, 0b00000001, 0b00000000)
        b = m[i+1]
        mask |= ifelse(b == COMMA || b == NEWLINE || b == RETURN, 0b00000010, 0b00000000)
        b = m[i+2]
        mask |= ifelse(b == COMMA || b == NEWLINE || b == RETURN, 0b00000100, 0b00000000)
        b = m[i+3]
        mask |= ifelse(b == COMMA || b == NEWLINE || b == RETURN, 0b00001000, 0b00000000)
        b = m[i+4]
        mask |= ifelse(b == COMMA || b == NEWLINE || b == RETURN, 0b00010000, 0b00000000)
        b = m[i+5]
        mask |= ifelse(b == COMMA || b == NEWLINE || b == RETURN, 0b00100000, 0b00000000)
        b = m[i+6]
        mask |= ifelse(b == COMMA || b == NEWLINE || b == RETURN, 0b01000000, 0b00000000)
        b = m[i+7]
        mask |= ifelse(b == COMMA || b == NEWLINE || b == RETURN, 0b10000000, 0b00000000)
        bitmap[j] = mask
        j += 1
    end
    return bitmap
end



end # module
