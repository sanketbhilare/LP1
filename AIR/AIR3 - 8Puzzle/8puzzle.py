class Node:
    '''A node for A* path finding'''
    def __init__(self, data, level, fval):
        '''Initialize the node with the data, the level of the node and the calculated fvalue'''
        self.data = data
        self.level = level
        self.fval = fval
    
    def generate_child(self):
        '''Generate child nodes from the given node by moving the blank space either (up, down, left, right)'''
        x, y = self.find(self.data, '_')#in the input data, if blank space is found, it's coordinates are stored in x and y respectively
        '''val_list contains the position values for moving the blank space up,down,left,right resp'''
        val_list = [[x,y-1], [x, y+1], [x-1, y], [x+1, y]]
        children = []
        for i in val_list:                                    #provided the coordinates in val_list are not none,
            child = self.shuffle(self.data, x, y, i[0], i[1]) #exchange the blank space with the value in the provided coordinates
            #print(child)
            if child is not None:
                child_node = Node(child,self.level + 1, 0)    #child_node is the value that will be printed as the next matrix
                children.append(child_node)
        return children
    
    def shuffle(self, puz, x1, y1, x2, y2):
        '''Moves the blank space in the given direction and if the position value is out of limits return None'''
        if x2 >= 0 and x2 < len(self.data) and y2 >= 0 and y2 < len(self.data):
            temp_puz = []
            temp_puz = self.copy(puz) #creates a new matrix that is the updated matrix
            temp = temp_puz[x2][y2]
            temp_puz[x2][y2] = temp_puz[x1][y1]
            temp_puz[x1][y1] = temp
            return temp_puz
        else:
            return None
        
    def copy(self, root):
        '''Copy the function to create a similar matrix of the given node'''
        temp = []
        for i in root:
            t = []
            for j in i:
                t.append(j)
            temp.append(t)
        return temp
        
    def find(self, puz, x):
        '''Used to find the position of the blank space'''
        for i in range(len(self.data)):
            for j in range(len(self.data)):
                if puz[i][j] == x:
                    return i,j
                
class Puzzle:
    def __init__(self,size):    
        '''Initialize the size of the puzzle by the specified size, open and closed lists are empty'''
        self.n = size
        self.open = []
        self.closed = []
        
    def accept(self):
        '''Accepts input from the user and stores in puz list'''
        puz = []
        for i in range(self.n):
            temp = input().split()
            puz.append(temp)
        return puz
    
    def f(self, start, goal):
        '''Heuristic Function to calculate heuristic value f(x) = h(x) + g(x)'''
        return self.h(start.data, goal) + start.level
    
    def h(self, start, goal):
        '''Calculates the difference between the given puzzles'''
        temp = 0
        for i in range(self.n):
            for j in range(self.n):
                if start[i][j] != goal[i][j] and start[i][j] != '_':
                    temp += 1
        return temp
    
    def process(self):
        print('Enter the start state matrix\n')
        start = self.accept() #input is taken from the user
        print('Enter the goal state matrix\n')
        goal = self.accept() #input is taken from the user
        '''Code to check whether the given goal state is reachable or not'''
        cnt = 0
        l=[]
        for i in range(self.n):
            for j in range(self.n):
                    l.append(goal[i][j])
        for i in range(len(l)):
            print(l[i])
        for i in range(len(l)):
            if l[i] != '_':
                for j in range(i,9):
                    if l[j] != '_' and l[i] > l[j]:
                        cnt += 1
        print("Inversions required:")
        print (cnt)
        if cnt%2 != 0:
            print("...goal state not reachable...")
            return
        '''Do this only if the goal is reachable'''
        start = Node(start, 0, 0) #input, 0, 0
        start.fval = self.f(start, goal)
        self.open.append(start)
        print('\n\n')
        while True:
            cur = self.open[0]
            print('')
            print('  |')
            print('  |')
            print(" \\\'/\n")
            for i in cur.data:
                for j in i:
                    print(j, end=' ')
                print()
            '''If the difference between current and goal node is 0 we have reached the goal node'''
            if(self.h(cur.data, goal) == 0):
                break
            for i in cur.generate_child():
                i.fval = self.f(i, goal)
                self.open.append(i)
            self.closed.append(cur)
            del self.open[0]
            '''sort the open list according to f value'''
            self.open.sort(key = lambda x:x.fval, reverse = False)

puz = Puzzle(3)
abc=puz.process()


# Start state:
'''
1 2 3          
4 5 6
7 8 _

''' 

# Reachable Goal state:
'''
1 8 2
_ 4 3 
7 6 5
'''

# Unreachable Goal State:
'''
8 1 2
_ 4 3 
7 6 5
'''