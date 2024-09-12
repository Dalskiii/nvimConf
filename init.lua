require("theprimeagen")

vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true })

-- Function to read the config file
local function ReadConfig()
    local config_file_path = vim.fn.getcwd() .. "/config.txt"
    local config = {}
    local file = io.open(config_file_path, "r")

    if file then
        local is_empty = true
        for line in file:lines() do
            is_empty = false
            for k, v in string.gmatch(line, "(%w+):%s*(%S+)") do
                config[k] = v
            end
        end
        file:close()

        -- Check if config is empty
        if is_empty then
            print("Config file is empty, using default compiler: g++")
            config["compiler"] = "g++"
        end
    else
        -- Config file doesn't exist
        print("Config file not found, using default compiler: g++")
        config["compiler"] = "g++"
    end

    return config
end

-- Function to compile and run the C++ project
function CompileCppProject()

    vim.cmd('wa')
    local exe_cpp_path = vim.fn.getcwd() .. "/bin"

    if vim.fn.isdirectory(exe_cpp_path) == 0 then
        vim.fn.mkdir("bin", "p")
    end

    -- Read the config to get the compiler
    local config = ReadConfig()
    local compiler = config["compiler"] or "g++" -- Default to g++ if not specified

    -- Compile all .cpp files in source/ with headers from headers/ and output to bin/output
    local cmd = compiler .. " -std=c++17 -Wall -O2 source/*.cpp -Iheaders -o bin/output -lstdc++"

    -- Run the command and check for success
    -- Save all open and modified files before compiling

    local result = vim.fn.system(cmd)

    -- If compilation is successful, try to run the executable
    if vim.v.shell_error == 0 then
        print("Compilation succeeded. Trying to run the executable...")

        -- Try to run the executable and capture the output and any errors
        local run_result = vim.fn.system("./bin/output")

        -- Check if the executable ran successfully
        if vim.v.shell_error == 0 then
            print("Program executed successfully:\n\n" .. run_result)
        else
            -- Check if it's a runtime error (segmentation fault, etc.) or a system error (architecture, etc.)
            if run_result:find("Exec format error") then
                print("Failed to run the executable: Incompatible system architecture.")
            else
                print("Failed to run the executable due to runtime errors.")
                print("Runtime Error Output:\n" .. run_result)
            end
        end
    else
        print("Compilation failed:\n" .. result)
    end
end

-- Bind the function to F5
vim.api.nvim_set_keymap('n', '<F5>', ':lua CompileCppProject()<CR>', { noremap = true, silent = true })

-- Lua function to initialize a basic C++ project structure
function InitCppProject()
    -- Create the necessary directories
    vim.fn.mkdir("source", "p")
    vim.fn.mkdir("headers", "p")
    vim.fn.mkdir("bin", "p")
    -- Create the config.txt file with default compiler if it doesn't exist
    local config_file_path = "config.txt"

    if vim.fn.filereadable(config_file_path) == 0 then
        local file = io.open(config_file_path, "w")
        file:write("This file is used by Jens Dalsgaard for his neovim config\ncompiler: g++\n")
        file:close()
        print("Created config.txt with default compiler: g++")
    else
        print("config.txt already exists")
    end

    -- Create a basic main.cpp file if it doesn't already exist
    local main_cpp_path = "source/main.cpp"
    if vim.fn.filereadable(main_cpp_path) == 0 then
        local file = io.open(main_cpp_path, "w")
        file:write([[
#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
]])
        file:close()
        print("Created source/main.cpp")
    else
        print("source/main.cpp already exists")
    end
end

-- Map to F6 for initializing the project structure
vim.api.nvim_set_keymap('n', '<F6>', ':lua InitCppProject()<CR>', { noremap = true, silent = true })
