t = '''
149
87
67
45
76
29
107
88
4
11
118
160
20
115
130
91
144
152
33
94
53
148
138
47
104
121
112
116
99
105
34
14
44
137
52
2
65
141
140
86
84
81
124
62
15
68
147
27
106
28
69
163
97
111
162
17
159
122
156
127
46
35
128
123
48
38
129
161
3
24
60
58
155
22
55
75
16
8
78
134
30
61
72
54
41
1
59
101
10
85
139
9
98
21
108
117
131
66
23
77
7
100
51
'''

t1 = '''
28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3
'''

def parse(t):
    data = [0] + [int(n) for n in t.strip().split()]
    data.sort()
    data.append(data[-1] + 3)
    return data

def p1(t):
    data = parse(t)
    d1 = 0
    d3 = 0
    for x, y in zip(data, data[1:]):
        if y - x == 3:
            d3 += 1
        if y - x == 1:
            d1 += 1
    return d1, d3, d1 * d3

def p2(t):
    data = parse(t)
    groups = [[]]
    for x, y in zip(data, data[1:]):
        groups[-1].append(x)
        if y - x == 3:
            groups.append([])
    r = 1
    for x in [count(x) for x in groups]:
        r *= x
    return r

def count(xs):
    l = len(xs)
    if l == 1 or l == 0:
        return 1
    elif l == 2:
        return 1
    elif l == 3:
        return 2
    elif l == 4:
        return 4
    elif l == 5:
        return 7


print(p1(t))
print(p2(t))
