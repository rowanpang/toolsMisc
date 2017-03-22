.PHONY:all
all:normal memleak

normal:normal.c
	@gcc -g -Wall $< -o normal

memleak:memleak.c
	@gcc -g -Wall $< -o memleak
clean:
	@-rm normal memleak
