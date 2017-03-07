//===-- X86InstrMPX.td - MPX Instruction Set ---------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file describes the X86 MPX instruction set, defining the
// instructions, and properties of the instructions which are needed for code
// generation, machine code emission, and analysis.
//
//===----------------------------------------------------------------------===//

//see include/llvm/Target/Target.td for meaning of
//mayLoad/mayStore/hadSideEffects

multiclass mpx_bound_make<bits<8> opc, string OpcodeStr> {
  let mayLoad=0, mayStore=0, hasSideEffects=0, hasREX_WPrefix = 0 in {
    def 32rm: I<opc, MRMSrcMem, (outs BNDR:$dst), (ins i32mem:$src),
                OpcodeStr#"\t{$src, $dst|$dst, $src}",[],IIC_MPX_BNDMK>,
                Sched<[]>,
                Requires<[HasMPX, Not64BitMode]>;
    def 64rm: RI<opc, MRMSrcMem, (outs BNDR:$dst), (ins i64mem:$src),
                OpcodeStr#"\t{$src, $dst|$dst, $src}",[],IIC_MPX_BNDMK>,
                Sched<[]>,
                Requires<[HasMPX, In64BitMode]>;
  }
}

defm BNDMK : mpx_bound_make<0x1B, "bndmk">, XS;

multiclass mpx_bound_check<bits<8> opc, string OpcodeStr> {
  let mayLoad=0, mayStore=0, hasSideEffects = 1, hasREX_WPrefix = 0 in {
    def 32rm: I<opc, MRMSrcMem, (outs), (ins  BNDR:$src1, i32mem:$src2),
                OpcodeStr#"\t{$src2, $src1|$src1, $src2}", [], IIC_MPX_BNDCHK>,
                Sched<[]>,
                Requires<[HasMPX, Not64BitMode]>;
    def 64rm: RI<opc, MRMSrcMem, (outs), (ins  BNDR:$src1, i64mem:$src2),
                OpcodeStr#"\t{$src2, $src1|$src1, $src2}", [], IIC_MPX_BNDCHK>,
                Sched<[]>,
                Requires<[HasMPX, In64BitMode]>;
    def 32rr: I<opc, MRMSrcReg, (outs), (ins  BNDR:$src1, GR32:$src2),
                OpcodeStr#"\t{$src2, $src1|$src1, $src2}", [], IIC_MPX_BNDCHK>,
                Sched<[]>,
                Requires<[HasMPX, Not64BitMode]>;
    def 64rr: RI<opc, MRMSrcReg, (outs), (ins  BNDR:$src1, GR64:$src2),
                OpcodeStr#"\t{$src2, $src1|$src1, $src2}", [], IIC_MPX_BNDCHK>,
                Sched<[]>,
                Requires<[HasMPX, In64BitMode]>;
  }
}

defm BNDCL : mpx_bound_check<0x1A, "bndcl">, XS;
defm BNDCU : mpx_bound_check<0x1A, "bndcu">, XD;
defm BNDCN : mpx_bound_check<0x1B, "bndcn">, XD;


let mayLoad=0, mayStore=0, hasSideEffects = 0, hasREX_WPrefix = 0 in {
    def BNDMOVRMrr   : I<0x1A, MRMSrcReg, (outs BNDR:$dst), (ins BNDR:$src),
                        "bndmov\t{$src, $dst|$dst, $src}", [], IIC_MPX_BNDMOV_RR>,
                        Sched<[]>,
                        PD,
                        Requires<[HasMPX]>;
}

let mayLoad = 1, mayStore=0, hasSideEffects = 0, hasREX_WPrefix = 0 in {
    def BNDMOVRM32rm : I<0x1A, MRMSrcMem, (outs BNDR:$dst), (ins i64mem:$src),
                        "bndmov\t{$src, $dst|$dst, $src}", [], IIC_MPX_BNDMOV_RM>,
                        Sched<[]>,
                        PD,
                        Requires<[HasMPX, Not64BitMode]>;
    def BNDMOVRM64rm : RI<0x1A, MRMSrcMem, (outs BNDR:$dst), (ins i128mem:$src),
                        "bndmov\t{$src, $dst|$dst, $src}", [], IIC_MPX_BNDMOV_RM>,
                        Sched<[]>,
                        PD,
                        Requires<[HasMPX, In64BitMode]>;
}

let mayLoad=0, mayStore=0, hasSideEffects = 0, hasREX_WPrefix = 0 in {
    def BNDMOVMRrr   : I<0x1B, MRMDestReg, (outs BNDR:$dst), (ins BNDR:$src),
                        "bndmov\t{$src, $dst|$dst, $src}", [], IIC_MPX_BNDMOV_RR>,
                        Sched<[]>,
                        PD,
                        Requires<[HasMPX]>;
}

let mayLoad=0, mayStore = 1, hasSideEffects = 0, hasREX_WPrefix = 0 in {
    def BNDMOVMR32mr : I<0x1B, MRMDestMem, (outs), (ins i64mem:$dst, BNDR:$src),
                        "bndmov\t{$src, $dst|$dst, $src}", [], IIC_MPX_BNDMOV_MR>,
                        Sched<[]>,
                        PD,
                        Requires<[HasMPX, Not64BitMode]>;
    def BNDMOVMR64mr : RI<0x1B, MRMDestMem, (outs), (ins i128mem:$dst, BNDR:$src),
                        "bndmov\t{$src, $dst|$dst, $src}", [], IIC_MPX_BNDMOV_MR>,
                        Sched<[]>,
                        PD,
                        Requires<[HasMPX, In64BitMode]>;
}


let mayLoad = 0, mayStore = 1, hasSideEffects = 0, hasREX_WPrefix = 0 in {
    def BNDSTXmr:      I<0x1B, MRMDestMem, (outs), (ins i64mem:$dst, BNDR:$src),
                        "bndstx\t{$src, $dst|$dst, $src}", [], IIC_MPX_BNDSTX>,
                        Sched<[]>,
                        PS,
                        Requires<[HasMPX]>;
}
let mayLoad =  1, mayStore = 0, hasSideEffects = 0, hasREX_WPrefix = 0 in {
    def BNDLDXrm:      I<0x1A, MRMSrcMem, (outs BNDR:$dst), (ins i64mem:$src),
                        "bndldx\t{$src, $dst|$dst, $src}", [], IIC_MPX_BNDLDX>,
                        Sched<[]>,
                        PS,
                        Requires<[HasMPX]>;
}
//bndmov patterns
//only support 64bit platform for now
//see ./include/llvm/Target/TargetSelectionDAG.td for Pat class definition
def loadx86bnd  : PatFrag<(ops node:$ptr), (x86bnd (load node:$ptr))>;
def storex86bnd  : PatFrag<(ops node:$val, node:$ptr),
                           (store node:$val, node:$ptr),
[{
  return cast<StoreSDNode>(N)->getAlignment()>=16;
}]>;

def : Pat<(loadx86bnd addr:$src),
          (COPY_TO_REGCLASS (BNDMOVRM64rm addr:$src), BNDR)>;

def : Pat<(storex86bnd (x86bnd BNDR:$src), addr:$dst ),
          (BNDMOVMR64mr addr:$dst, BNDR:$src)>;

