object "YulString" {
    code {
        // Deploy the contract
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))        
    }

    object "runtime" {
        code {
            // don't accept value
            require(iszero(callvalue()))

            switch selector()

            case 0x20965255 { // getValue
                value()
            }

            case 0x93a09352 { // setValue(string)
                setValue()
            }

            default {
                revert(0, 0)
            }

            function value() {
                // Read the data from variable slot
                let head := sload(variableSlot())

                // For strings < 32 bytes the string is encoded in as many of the 
                // the first 31 bytes that is needed, while the length is encoded
                // in the last byte. 
                // 0             15             30 |                 31 |
                // 0            0xf           0x1e |               0x1f |
                // | ............................. |<- encoded length ->|
                //                                   last BYTE of head

                // For strings >= 32 bytes, the length is encode in the low word
                // of the variable slot, while the string is stored in as many
                // slots as needed, starting at keccak256(variableSlot()).
                // 0                15 |   16                32 |
                // 0              0x0f | 0x10              0x1f |
                // | ..................| <-- encoded length  -->|
                //                         last 16 BYTES of head
                // NOTE: The formula for encoding the length is:
                // encodedLength = length * 2      if length < 32
                //                 length * 2 + 1  otherwise
                // This means we can inspect the last bit of the encoded length
                // to determine if the string is < 32 bytes


                // isOdd(head)
                switch and(head, 0x1)

                case 1 { // odd
                    // get length from entire low bytes.
                    let len := shr(1, lowBytes(head))

                    // Use 0x80 as the starting slot for the return string
                    let retSlot := 0x80

                    // The return encoding for a string, a dynamic type is
                    // 0xstart: points to slot with length
                    // 0xstart + 0x20: length of string
                    // 0xstart + 0x40: first word of string
                    // 0xstart + ... : as many slots as needed to hold the string

                    // 1) Store the slot for the length. 
                    mstore(retSlot, 0x20) // str ptr head

                    // Bump return slot
                    retSlot := add(retSlot, 0x20)

                    // 2) Store the length
                    mstore(retSlot, len)  // str len

                    // Start with words, which represent:
                    // a) ptr to string length (=0x20)
                    // b) string length
                    let returnSize := 0x40 

                    // Get the storage slot for the first word of the string
                    mstore(0x00, variableSlot())
                    let slot := keccak256(0x00, 0x20)

                    // Calculate word count for output
                    let count := slotsForLength(len)

                    for {} gt(count, 0) { count := sub(count, 1)} {
                        // inc loc to next slot
                        retSlot := add(retSlot, 0x20) 

                        // 3..n) Record next word for output
                        mstore(retSlot, sload(slot))

                        // inc position key for next word of string
                        slot := add(slot, 1)

                        // update size for output
                        returnSize := add(returnSize, 0x20)
                    }
                    returnString(0x80, returnSize)
                }

                // Length is < 32, so the string is encoded in the last byte
                // of the word.
                default {  // even
                    // get length from last BYTE
                    let len := shr(1, lastByte(head))
                    mstore(0x00, 0x20)
                    mstore(0x20, len)
                    mstore(0x40, head)
                    mstore8(0x5f, 0)
                    returnString(0x00, 0x60)
                }  
            }

            function setValue() {
                // Calldata layout:
                // 0. 0x000 (000) : 0x20
                // 1. 0x020 (032) : length
                // 2. 0x040 (064) : start of data

                let len := lowBytes(decodeAsUint(1))
                if iszero(len) { return(0, 0) }

                let encodedLength := shl(1, len)

                switch gt(len, 31)
                case 1 {
                    // when strlen >= 32, we store the encoded length which is
                    // length * 2 + 1
                    encodedLength := add(encodedLength, 1)

                    // save encoded length at the variable's storage slot
                    sstore(variableSlot(), encodedLength)

                    // the string data is stored in as many slots as needed 
                    // beginning at keccak256(variableSlot())
                    mstore(0x00, variableSlot())
                    let ptr := keccak256(0x00, 0x20)

                    let offset := 2 // start of data in calldata
                    let count := slotsForLength(len)

                    for {} gt(count, 0) {} {
                        sstore(ptr, decodeAsUint(offset))
                        ptr := add(ptr, 1)
                        offset := add(offset, 1)
                        count := sub(count, 1)
                    }
                }

                default {
                    // when strlen < 32, the encoded length is stored in the low
                    // byte and the string encoding in the high byte.
                    let v := decodeAsUint(2)
                    sstore(variableSlot(), or(v, lastByte(encodedLength)))
                }                
            }            
            /* ---------- storage layout ----------- */
            function variableSlot() -> s {
                // declare the position of the string's variable slot,
                // which will be zero for this exercise.
                s := 0
            }

            /* ---------- calldata decoding ----------- */
            function selector() -> s {
                // Extract selector from calldata's first word. A word is 32 bytes
                // and the selector is the first 4 bytes, shift-right the first
                // word by (32-8) bytes. Converting bytes to bits:
                // 24 bytes * 8 bits/bytes = 192 = 0xe0
                s := shr(0xe0, calldataload(0))
            }

            function decodeAsUint(offset) -> v {
                let ptr := add(4, mul(offset, 0x20))
                if lt(calldatasize(), add(ptr, 0x20)) {
                    revert(0, 0)
                }
                v := calldataload(ptr)
            }

            /* ---------- calldata encoding ---------- */

            function returnString(p, l) {
                return(p, l)
            }

            /* ---------- utility functions ---------- */

            function require(condition) {
                if iszero(condition) { revert(0, 0) }
            }

            function lowBytes(w) -> b {
                b := and(w, 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff)
            }

            function highBytes(w) -> b {
                b := and(w, 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000)
            }

            function lastByte(w) -> b {
                b := and(w, 0x00000000000000000000000000000000000000000000000000000000000000ff)
            }

            function slotsForLength(len) -> s {
                // (len // 32) + 1
                s := add(shr(5, len), 1)

                // if len % 32 == 0, subtract 1
                if eq(shl(5, shr(5, len)), len) {
                    s := sub(s, 1)
                }
            }
        }
    }
}




