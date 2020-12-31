def main():
    TestE2E().test_runGamingSession()


class TestE2E:

    def test_runGamingSession(self):
        if __name__ == "__main__":
            print(mp.cpu_count())
            timestart = time.clock()*1000

            listoftrees = []
            pool = pools.ProcessPool(4)
            testcases = [2000]*8
            results = pool.map(self.runGamingSession, testcases)
            for result in results:
                
                print("Gaming Session Result - tree size:"+str(len(result)))
                listoftrees.append(result)
            lasttree = {}
            for tree in listoftrees:
                lasttree = self.combine_dicts(tree, lasttree,self.addTotalValueAndTotalTimesVisited)
            print(len(lasttree))
            print(time.clock()*1000-timestart)
            ###BASELINE - 64 seconds for 16000 games spread across 4 cores, with for loops
    
    def runGamingSession(self,numiterations):
        print("rungamingsession")
        gamingSession = GamingSession(Player(),Player())
        gamingsessiontree = gamingSession.runGamingSession(numiterations)
        return gamingsessiontree

    def combine_dicts(self, a, b, op):
        return dict(list(a.items()) + list(b.items()) +
        [(k, op(a[k], b[k])) for k in set(b) & set(a)])

    def addTotalValueAndTotalTimesVisited(self,a,b):
        return map(operator.add,a,b)


if __name__ == '__main__':
    main()