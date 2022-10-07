import numpy as np

BOARDS = [0,1,2]
CHANNELS = [8,8]

def main():
    
    N_COILS = np.sum(CHANNELS)

    CURRENT = 0.3
    b0_map = CURRENT * np.eye(N_COILS)

    b0_map_str = str(b0_map)
    for line in str(b0_map).split('\n'):
        #line = ','.join(line.split(' '))
        line = line.split('\n')[0]
        line = line.replace('  ', ' ').replace('[','{').replace(']','}')
        line = line.lstrip()
        line = line.replace(' ',',',N_COILS - 1)
        print(line + ',')

    


if __name__ == "__main__":

    main()
