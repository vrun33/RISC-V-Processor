// Converts hexadecimal to decimal
// Input: number of test cases, followed by hexadecimal numbers

// #include <iostream>
// #include <iomanip>
// using namespace std;

// int main() {
//     int t;
//     cin >> t;
    
//     while (t--) {
//         unsigned int num;
//         cin >> num;
//         cout << setw(8) << setfill('0') << hex << uppercase << num << endl;
//     }
    
//     return 0;
// }

// Converts decimal to hexadecimal
// Input: number of test cases, followed by decimal numbers

#include <iostream>
#include <iomanip>
using namespace std;

int main() {
    int t;
    cin >> t;
    
    while (t--) {
        string hexNum;
        cin >> hexNum;
        unsigned int num = stoi(hexNum, nullptr, 16);
        cout << num << endl;
    }
    
    return 0;
}
