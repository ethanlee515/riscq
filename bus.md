##

Exception in thread "main" java.lang.ArrayIndexOutOfBoundsException: Index -1 out of bounds for length 4096

solution: add simPublic to the bus of tilelink

## 

tilelink failure ???

problem: address overlap

solution: specify the address range by `at SizeMapping(base, size)`

##

words in elf are padded by `f` instead of `0`

problem: scala size extends words read from elf

solution: 
```scala
      for (d <- data) { // d is of type byte
        val unsigned = d.toInt & 0xff // remove the size extension by leave only the first byte
        val res = f"${unsigned}%02X"
        print(s"${res} ")
      }
```