def generate_flooded_hex():
    # Keep this absolute path as is
    target_path = "/data/thatton9/vortex4dice/dice_new/rtl/cgra_core/ldst_unit/test_cases.hex"
    
    with open(target_path, 'w') as f:
        # Fill the memory range
        for i in range(4096):
            # 64 hex characters = 32 bytes = 256 bits
            # This ensures NO MATTER WHERE the core looks in the line,
            # it will see DEADBEEF.
            f.write("deadbeefcafed00d" * 4 + "\n")
    
    print(f"File successfully updated at {target_path}")

if __name__ == "__main__":
    generate_flooded_hex()