module newcsv

using Mmap

const COMMA = UInt8(',')
const NEWLINE = UInt8('\n')
const RETURN = UInt8('\r')

function parse(file="/home/chronos/user/Downloads/.julia/v0.7/CSV/test/test_files/Fielding.csv")
    m = read(file)
    #bitmap = zeros(UInt8, fld1(length(m), 8))
    bitmap = zeros(UInt8, length(m))
    return parse(m, bitmap)
end
function parse(m, bitmap)
    len = length(bitmap)
    @simd for j = 1:len
        @inbounds begin
        b = m[j]
        field = ifelse(b == COMMA, 0x01, 0x00) | ifelse(b == NEWLINE, 0x01, 0x00)
        bitmap[j] = field
        end
    end
    fields = sum(bitmap)
    results = Vector{Int}(uninitialized, fields)
    i = 1
    @inbounds for j = 1:len
        if bitmap[j] == 0x01
            results[i] = j
            i += 1
        end
    end
    return results
end
function parse2(file="/home/chronos/user/Downloads/.julia/v0.7/CSV/test/test_files/Fielding.csv")
    m = Mmap.mmap(file)
    bitmap = zeros(UInt64, fld1(length(m), 64))
    temp = zeros(UInt8, 64)
    temp2 = UInt64[0]
    return parse2(m, bitmap, temp, temp2)
end
function parse2(m, bitmap, temp, temp2)
    i = 0
    x = 1
    len = length(m)
    while i < len
        @simd for j = 1:64
            @inbounds begin
            b = m[i+j]
            temp[j] = ifelse(b == COMMA, 0x01, 0x00) | ifelse(b == NEWLINE, 0x01, 0x00)
            end
        end
        #@simd for j = 1:64
        #    @inbounds temp2[1] |= UInt64(temp[j]) << j-1
        #end
        #bitmap[x] = temp2[1]
        i += 64
        x += 1
    end
    return bitmap
end

function parse3(file="/home/chronos/user/Downloads/.julia/v0.7/CSV/test/test_files/Fielding.csv")
    m = read(file);
    results = zeros(Int, div(length(m), 2))
    temp = zeros(UInt8, 64)
    return parse3(m, results, temp)
end
function parse3(m, results, temp)
    len = length(m)
    i = 0
    field = 1
    while i < len
        @simd for j = 1:64
            @inbounds begin
                b = m[j]
                field = ifelse(b == COMMA, 0x01, 0x00) | ifelse(b == NEWLINE, 0x01, 0x00)
                temp[j] = field
            end
        end
    end
end

function parse4(file="/home/chronos/user/Downloads/.julia/v0.7/CSV/test/test_files/Fielding.csv")
    m = read(file);
    bitmap = zeros(UInt8, fld1(length(m), 8))
    return parse4(m, bitmap)
end

function parse4(m, bitmap)
    i = 1
    @simd for j = 1:length(bitmap)
        i = 8 * (j-1) + 1
        @inbounds bitmap[j] = ifelse((m[i]   == COMMA) | (m[i]   == NEWLINE), 0b00000001, 0x00) |
               ifelse((m[i+1] == COMMA) | (m[i+1] == NEWLINE), 0b00000010, 0x00) |
               ifelse((m[i+2] == COMMA) | (m[i+2] == NEWLINE), 0b00000100, 0x00) |
               ifelse((m[i+3] == COMMA) | (m[i+3] == NEWLINE), 0b00001000, 0x00) |
               ifelse((m[i+4] == COMMA) | (m[i+4] == NEWLINE), 0b00010000, 0x00) |
               ifelse((m[i+5] == COMMA) | (m[i+5] == NEWLINE), 0b00100000, 0x00) |
               ifelse((m[i+6] == COMMA) | (m[i+6] == NEWLINE), 0b01000000, 0x00) |
               ifelse((m[i+7] == COMMA) | (m[i+7] == NEWLINE), 0b10000000, 0x00)
    end
    return bitmap
end

end # module
