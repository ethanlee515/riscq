from elftools.elf.elffile import ELFFile
from elftools.elf.constants import SH_FLAGS


def load_elf_word(filename, write_word, offset):
  with open(filename, 'rb') as f:
    elf = ELFFile(f)
    for section in elf.iter_sections():
      # print(f"Section name: {section.name}, type: {section['sh_type']}")
      if((section['sh_flags'] & SH_FLAGS.SHF_ALLOC)):
        # print(f"addr: {section['sh_addr']}")
        addr = section['sh_addr']
        data = section.data()
        for i in range(0, len(data), 4):
          word = data[i:i+4]
          write_word(addr + i + offset, word)

def print_addr_data(addr, data):
  print(f"{hex(addr)} {data.hex()}")

load_elf_word("test.elf", print_addr_data, -0x70000000)
