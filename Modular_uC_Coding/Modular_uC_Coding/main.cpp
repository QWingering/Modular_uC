#include <iostream>
#include <string>
#include <fstream>
#include <vector>
#include <stdlib.h>

using namespace std;

int compile();
string decode(string line);
string str_int_to_bin(string to_convert, int out_size);
string int_to_str_bin(int to_convert, int out_size);

vector<int> label_pos;
vector<string> label_name;


int main()
{

    cout << "This is the compiler for the M_uC (Modular micro-controller)" << endl;
    compile();
    cin.ignore(1);
    cin.ignore(1);
    return 0;

}

int compile()
{
    string filename;
    cout << "enter file name : ";
    cin >> filename;
    ifstream file(filename.data());
    ofstream out_file("out.txt", ios::trunc);

    bool error_state = false;

    int line_count = 0;
    int i;


    vector<string> instruction_list;
    string line;
    bool can_read = true;

    if(file && out_file)
    {
        cout << "--- checking for labels ---" << endl <<"labels are : (format : name@line)" << endl;
        while(can_read)//stores label and instructions
        {
            can_read = getline(file,line);

            if(can_read == true)
            {
                if(line.size()>0) //do not read empty lines
                {
                    if(line[0] == '.') //if the line is a label
                    {
                        label_name.push_back(line.substr(1));
                        cout << line.substr(1) << "@" << line_count << endl;
                        label_pos.push_back(line_count);
                    }
                    else if(line[0] != '-')//if the line is an instruction and not commentary
                    {
                        instruction_list.push_back(line/*.substr(0,line.find("-"))*/);
                        line_count++;
                    }
                }
            }
        }
        cout << "--- decoding ---" << endl;
        string tmp;
        for(i = 0; i<instruction_list.size(); i++)
        {
            tmp = decode(instruction_list[i]);
            if(tmp =="ERROR")
            {
                error_state = true;
            }
            out_file << tmp << endl;
            cout << i <<":  "<< instruction_list[i] << "  -  " << tmp << endl;

        }
        if(error_state == true)
        {
            cout << "WARNING : ERRORS HAVE BEEN DETECTED" << endl;
        }
        cout << "compiled file should be in \"out.txt\"" <<endl;
    }
    else
    {
        cout << "unable to open the file" << endl;
    }
}

string decode(string line)
{
    //SEPARATE DIFFERENT PARTS
    string instruction;
    int pos1, pos2;
    pos2 = line.find(" ");
    instruction = line.substr(0,pos2);
    string parameters[5] = "";
    int i;
    for(i=0;i<5;i++) //find parameters
    {
        pos1 = pos2;
        pos2 = line.find(",", pos2+1);
        if(pos1 >= line.size())
            break;
        parameters[i] = line.substr(pos1+1,pos2-pos1-1);
    }

    //DECODE
    string binary_out = "" ;
    if(instruction == "NOP")
    {
        binary_out = "000000000000000000000000";
    }
    else if(instruction == "GOTO")
    {
        binary_out = "00010000";

        for(i=0;i<label_name.size();i++)
        {
            if(parameters[0]==label_name[i])
            {
                binary_out += int_to_str_bin(label_pos[i],16);
                break;
            }
        }
    }
    else if(instruction == "CALL")
    {
        binary_out = "00100000";

        for(i=0;i<label_name.size();i++)
        {
            if(parameters[0]==label_name[i])
            {
                binary_out += int_to_str_bin(label_pos[i],16);
                break;
            }
        }
    }
    else if(instruction == "RETURN")
    {
        binary_out = "001100000000000000000000";
    }
    else if(instruction == "MVMW")
    {
        binary_out = "0101";
        binary_out += str_int_to_bin(parameters[0],4);
        binary_out += str_int_to_bin(parameters[1],8);
        binary_out += str_int_to_bin(parameters[2],8);
    }
    else if(instruction == "MVWM")
    {
        binary_out = "0110";
        binary_out += str_int_to_bin(parameters[0],4);
        binary_out += str_int_to_bin(parameters[1],8);
        binary_out += str_int_to_bin(parameters[2],8);
    }
    else if(instruction == "LLW")
    {
        binary_out = "0111";
        binary_out += str_int_to_bin(parameters[0],4);
        binary_out += "00000000";
        binary_out += str_int_to_bin(parameters[1],8);
    }
    else if(instruction == "OP")
    {
        binary_out = "0100";
        binary_out += str_int_to_bin(parameters[3],4);
        binary_out += str_int_to_bin(parameters[1],4);
        binary_out += str_int_to_bin(parameters[2],4);
        binary_out += "0000";
        if(parameters[0]=="RETA")
        {
            binary_out+="0000";
        }
        else if(parameters[0]=="AND")
        {
            binary_out+="0001";
        }
        else if(parameters[0]=="OR")
        {
            binary_out+="0010";
        }
        else if(parameters[0]=="XOR")
        {
            binary_out+="0011";
        }
        else if(parameters[0]=="NOTA")
        {
            binary_out+="0100";
        }
        else if(parameters[0]=="ROTLA")
        {
            binary_out+="0101";
        }
        else if(parameters[0]=="ROTRA")
        {
            binary_out+="0110";
        }
        else if(parameters[0]=="SHFTLA")
        {
            binary_out+="0111";
        }
        else if(parameters[0]=="SHFTRA")
        {
            binary_out+="1000";
        }
        else if(parameters[0]=="ADD")
        {
            binary_out+="1001";
        }
        else if(parameters[0]=="SUB")
        {
            binary_out+="1010";
        }
        else if(parameters[0]=="DECA")
        {
            binary_out+="1011";
        }
        else
        {
            return "ERROR";
        }
    }
    else if(instruction == "OPSKI")
    {
        binary_out = "1000";
        if(parameters[3]=="")
        {
            binary_out +="0000";
        }
        else
        {
            binary_out += str_int_to_bin(parameters[3],4);
        }
        binary_out += str_int_to_bin(parameters[1],4);
        binary_out += str_int_to_bin(parameters[2],4);
        if(parameters[3]=="")
        {
            binary_out +="0000";
        }
        else
        {
            binary_out += "1111";
        }
        if(parameters[0]=="RETA")
        {
            binary_out+="0000";
        }
        else if(parameters[0]=="AND")
        {
            binary_out+="0001";
        }
        else if(parameters[0]=="OR")
        {
            binary_out+="0010";
        }
        else if(parameters[0]=="XOR")
        {
            binary_out+="0011";
        }
        else if(parameters[0]=="NOTA")
        {
            binary_out+="0100";
        }
        else if(parameters[0]=="ROTLA")
        {
            binary_out+="0101";
        }
        else if(parameters[0]=="ROTRA")
        {
            binary_out+="0110";
        }
        else if(parameters[0]=="SHFTLA")
        {
            binary_out+="0111";
        }
        else if(parameters[0]=="SHFTRA")
        {
            binary_out+="1000";
        }
        else if(parameters[0]=="ADD")
        {
            binary_out+="1001";
        }
        else if(parameters[0]=="SUB")
        {
            binary_out+="1010";
        }
        else if(parameters[0]=="DECA")
        {
            binary_out+="1011";
        }
        else
        {
            return "ERROR";
        }
    }
    else
    {
        return "ERROR";
    }

    if(binary_out.size() != 24)
    {
        return "ERROR";
    }
    binary_out = "\"" + binary_out + "\",";
    return binary_out;
}

string str_int_to_bin(string to_convert, int out_size)
{
    int a = atoi(to_convert.data());
    int i;
    string out(out_size,' ');
    for(i=0; i<out_size; i++)
    {
        out[out_size-1-i] = (a%2 + 48);
        a = a/2;
    }
    return out;
}

string int_to_str_bin(int to_convert, int out_size)
{
    int a = to_convert;
    int i;
    string out(out_size,' ');
    for(i=0; i<out_size; i++)
    {
        out[out_size-1-i] = (a%2 + 48);
        a = a/2;
    }
    return out;
}
