# **Reading from a File in a Verilog Testbench**

## **Introduction**

Reading from a file in Verilog is useful for automating testbenches, especially for feeding large sets of test inputs into a module. This tutorial explains how to read from a file line by line using standard Verilog file I/O functions.

## **Steps to Read a File in Verilog**

### **1. Open the File**

```verilog
integer file;
file = $fopen("test_cases.txt", "r");
if (file == 0) begin
    $display("Error: Cannot open file!");
    $finish;
end
```

- `$fopen("test_cases.txt", "r")` opens the file in read mode.

- If the file fails to open `(file == 0)`, it displays an error and stops execution.

### **2. Read the File Line by Line**

```verilog
while (!$feof(file)) begin
    integer scan_count;
    reg [8*100:1] line; // Buffer for the line content

    scan_count = $fgets(line, file);
    
    if (scan_count > 0) begin
        $display("Read Line: %s", line);
    end
end
```

- `$feof(file)` checks if the end of file (EOF) is reached.

- `$fgets(line, file)` reads a line from the file into the `line` buffer.

- If a valid line is read, it is displayed.

### **3. Extract Data from the Line**

```verilog
reg [31:0] instruction;
integer scan_count;

scan_count = $sscanf(line, "%d", instruction);
if (scan_count == 1) begin
    $display("Extracted Instruction: %d", instruction);
end
```

- `$sscanf(line, "%d", instruction)` extracts an integer value from `line`, and stores it in the `instruction` variable.

- If `scan_count == 1`, a valid integer was extracted.

### **4. Close the File**

```verilog
$fclose(file);
```

- `$fclose(file)` closes the file after reading is complete.

- Always close the file after reading to free system resources.

## **Key Functions for File Reading**

| Function | Description |
| --- | --- |
| `$fopen("filename", "r)` | Opens a file for reading. Returns file handle (0 if failed). |
| `$feof(file)` | Checks if the end of file is reached. Returns 1 if EOF, 0 otherwise. |
| `$fgets(buffer, file)` | Reads a line from the file into the `buffer`. Returns the number of bytes read. |
| `$sscanf(buffer, format, data)` | Extracts data from the buffer using the specified format. Returns the number of successful conversions. |
| `$fclose(file)` | Closes the file after reading is complete. |
