1) In omega terminal, cd to the directory where the cpp code is kept.

2) Compile the code with the command below

g++ dtree.cpp -o out

3) See the output of the code with below command:

./out <training_file_path> <test_file_path> <option> <pruning_thr>

For example you can run these commands below

./out <training_file_path> <test_file_path> optimized  50
./out <training_file_path> <test_file_path> randomized 50
./out <training_file_path> <test_file_path> forest3  50