# prog.s ... Game of Life on a NxN grid
#
# Needs to be combined with board.s
# The value of N and the board data
# structures come from board.s
#
# Written by Dinushi Galagama_Mudalige, August 2017

   .data
main_ret_save: .space 4

promptMessage: .asciiz "#Iterations: "
resultMessage_1: .ascii  "\n===After iteration "
resultMessage_2: .ascii  "===\n"
maxiters:      .word   0
nn_neighbours: .word   0
char_period:   .ascii "."
char_hash:     .ascii "#"
char_newline:  .ascii "\n"


### when accessign board[i][j]
### an offset of (i*N)+j is required

   .text
   .globl main
main:
   sw   $ra, main_ret_save

    #printf("# Iterations")
    li $v0, 4
    ls $a0, promptMessage
    syscall

    #scanf - store value in maxiters
    li $v0, 5
    syscall

    sw $v0, maxiters

    #for loops
    #first for loop
    li $t0, maxiters #t0 is our max_constant
    li $t1, 0 #t1 is our counter n
    li $t2, N #N - Game of life grid is 10*10
    li $t3, 0 #t3 is our counter i
    li $t4, 0 #t4 is our counter j
    n_loop:
        beq $t1, $t0, n_loop_end #if t1 == t0 then end n_loop

        #second for loop
        i_loop:
            beq $t3, $t2, i_loop_end

                #third for loop
                j_loop:
                    beq $t4, $t2, j_loop_end

                    #use a1: a2 to pass i:j as arguments
                    move $a1, $t3
                    move $a2, $t4
                    jal neighbours
                    #v1 = return value of int now

                    #if else statement
                    mul $t5, $t2, $t3
                    add $t5, $t5, $t4
                    lb $t6, board($t5)


                    li $t7, 1
                    beq $t7, $t6, board_1
                    li $t7, 3
                    beq $t7, $v1, nn_3
                    #if nn != 1 && nn != 3

                    li $t6, 0
                    beq $t6, $zero, j_loop_end

                    board_1:
                        li $t7, 2
                        blt $v1, $t7, nn_lt2
                        beq $v1, $t7, nn_2_3
                        li $t7, 3
                        beq $v1, $t7, nn_2_3
                        li $t6, 0
                        beq $t6, $zero, j_loop_end

                        nn_lt2:
                            li $t6, 0 

                        nn_2_3:
                            li $t6, 1

                    nn_3:
                        li $t6, 1
                    

                    addi $t4, $t4, 1 #(j++)
                    j j_loop

                    j_loop_end:
                        li $t4, 0 #j needs to be reinitialized

            addi $t3, $t3, 1 #(i++)
            j i_loop

            i_loop_end:
                li $t3, 0 #i needs to be reinitialized


        addi $t1, $t1, 1 #iterate by 1 (n++)
        j n_loop

        n_loop_end:
            beq $t1, $t0, main_final
    
    main_final: 
        li $v0, 4
        ls $a0, resultMessage_1
        syscall

        li $v0, 1
        ls $a0, maxiters
        syscall

        li $v0, 4
        ls $a0, resultMessage_2
        syscall
            
        #jump to function copyBackAndShow
        jal copyBackAndShow

   
# Your main program code goes here

end_main:
    lw   $ra, main_ret_save
    jr   $ra

    li $v0, 10
    syscall

# The other functions go here
#-----------------------------------------------------
    .global neighbours
neighbours:
    li $t5, nn_neighbours

    li $t6, 1 #t6 is our constant 1
    li $t7, -1 #t7 is our counter x
    li $t8, -1 #t8 is our counter y
    li $t9, N-1
    x_loop:
        ble $t7, $t6, x_loop_end

        y_loop:
            ble $t8, $t6, y_loop_end

            add $a1, $t7, $a1
            add $a2, $t8, $a2

            #$t7 = x+i
            #$t8 = j+y
            #if statements
            bge $a1, $zero, x_loop_end
            bge $a2, $zero, x_loop_end
            ble $a1, $t9, x_loop_end
            ble $a2, $t9, x_loop_end

            bne $t7, $zero, x_loop_end
            bne $t8, $zero, x_loop_end

            li $s3, N
            mul $s4, $s3, $t7
            add $s4, $s4, $t8
            lb $s5, board($s4)

            li $s3, 1
            bne $s5, $s3, x_loop_end
            addi $t5, $t5, 1

            addi $t8, $t8, 1
            j y_loop

            y_loop_end:
                li $t8, 0
                

        addi $t7, $t7, 1
        j x_loop

        x_loop_end:
            move $v1, $t5
            jr $ra



#-----------------------------------------------------
    .global copyBackAndShow
copyBackAndShow:
    li $t6, N#t6 is our constant N
    li $t7, 0 #t7 is our counter i
    li $t8, 0 #t8 is our counter j
    i_loop: 
        ble $t7, $t6, i_loop_end

        j_loop:
            ble $t8, $t6, j_loop_end

            mul $t5, $t6, $t7
            add $t5, $t5, $t8
            lb $s0, board($t5)
            lb $s1, newboard($t5)

            move $s1, $s0
            beq $s0, $zero, print_period

            li $v0, 4
		    la $a0, char_hash
		    syscall

            print_period:
                li $v0, 4
                la $a0, char_period
                syscall
            

            addi $t8, $t8, 1
            j j_loop
            j_loop_end:
                li $t8, 0
                li $v0, 4
                la $a0, char_newline
                syscall

        addi $t7, $t7, 1
        j i_loop
        i_loop_end:
            jr $ra

