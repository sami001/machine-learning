#include <cstdio>
#include <cstring>
#include <cmath>
#include <cstdlib>
#include <ctime>
#include <string>
#include <fstream>
#include <iostream>
#include <sstream>
#include <vector>
#include <algorithm>
using namespace std;
#define INF 1000000000

double toInt(string s){double r = 0;istringstream sin(s);sin >> r; return r;}

double u[10][10];
double uu[10][10];
double p[10][10][10][10][4];
int row, col;


vector< vector <double> > matrix;

void fileToMatrix(char* filename)
{
    ifstream myfile (filename);
    string line;
    while(getline(myfile, line)) {
        string temp;
        vector <double>v;
        for(int i = 0; i < line.length(); i++) {
            if(line[i] != ',') temp += line[i];
            else if(temp.length()) {
                if(temp == ".") v.push_back(2);
                else if(temp == "X") v.push_back(3);
                else v.push_back(toInt(temp));
                temp = "";
            }
        }
        if(temp == ".") v.push_back(2);
        else if(temp == "X") v.push_back(3);
        else v.push_back(toInt(temp));

        matrix.push_back(v);
    }
}

double calc(int i, int j)
{
    double mx = -INF;
    double sum;
    //up
    sum = 0;
    if(i == 0 || matrix[i-1][j] == 3) sum += (0.8 * u[i][j]);
    else sum += (0.8 * u[i-1][j]);
    if(j == 0 || matrix[i][j-1] == 3) sum += (0.1 * u[i][j]);
    else sum += (0.1 * u[i][j-1]);
    if(j == col-1 || matrix[i][j+1] == 3) sum += (0.1 * u[i][j]);
    else sum += (0.1 * u[i][j+1]);
    mx = max(mx, sum);

    //down
    sum = 0;
    if(i == row-1 || matrix[i+1][j] == 3) sum += (0.8 * u[i][j]);
    else sum += (0.8 * u[i+1][j]);
    if(j == 0 || matrix[i][j-1] == 3) sum += (0.1 * u[i][j]);
    else sum += (0.1 * u[i][j-1]);
    if(j == col-1 || matrix[i][j+1] == 3) sum += (0.1 * u[i][j]);
    else sum += (0.1 * u[i][j+1]);
    mx = max(mx, sum);
    //left
    sum = 0;
    if(j == 0 || matrix[i][j-1] == 3) sum += (0.8 * u[i][j]);
    else sum += (0.8 * u[i][j-1]);
    if(i == 0 || matrix[i-1][j] == 3) sum += (0.1 * u[i][j]);
    else sum += (0.1 * u[i-1][j]);
    if(i == row-1 || matrix[i+1][j] == 3) sum += (0.1 * u[i][j]);
    else sum += (0.1 * u[i+1][j]);
    mx = max(mx, sum);
    //right
    sum = 0;
    if(j == col-1 || matrix[i][j+1] == 3) sum += (0.8 * u[i][j]);
    else sum += (0.8 * u[i][j+1]);
    if(i == 0 || matrix[i-1][j] == 3) sum += (0.1 * u[i][j]);
    else sum += (0.1 * u[i-1][j]);
    if(i == row-1 || matrix[i+1][j] == 3) sum += (0.1 * u[i][j]);
    else sum += (0.1 * u[i+1][j]);
    mx = max(mx, sum);

    return mx;
}

int main(int argc, char* argv[])
{
    fileToMatrix(argv[1]);
    row = matrix.size();
    col = matrix[0].size();
    double non_terminal_reward = toInt(argv[2]);
    double gamma = toInt(argv[3]);
    int K = (int)toInt(argv[4]) + 1;


    for(int it = 0; it < K; it++) {
        memcpy ( u, uu, sizeof(uu) );

        for(int i = 0; i < row; i++) {
            for(int j = 0; j < col; j++) {
                if(matrix[i][j] == 3) uu[i][j] = 0;
                else if(matrix[i][j] == 1) uu[i][j] = 1;
                else if(matrix[i][j] == -1) uu[i][j] = -1;
                else {
                    uu[i][j] = non_terminal_reward + gamma * calc(i, j);
                }
            }
        }
        if(it == 0) continue;

    }

    for(int k = 0; k < row; k++) {
        printf("%6.3f", u[k][0]);
        for(int l = 1; l < col; l++) printf(",%6.3f", u[k][l]);
        printf("\n");
    } printf("\n");





    return 0;
}
