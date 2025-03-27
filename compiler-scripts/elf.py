from elftools.elf.elffile import ELFFile

with open('test.elf', 'rb') as f:
    elffile = ELFFile(f)

    for section in elffile.iter_sections():
        name = section.name
        address = section['sh_addr']
        data = section.data() if section['sh_type'] != 'SHT_NOBITS' else None

        print(f"Section: {name}")
        print(f"  Address: 0x{address:x}")
        print(f"  Size: {section['sh_size']} bytes")
        if data:
            print(f"  First 16 bytes: {data.hex()}")  # Preview
        else:
            print("  No data (SHT_NOBITS)")