#include <iostream>
//#include <fstream>
#include <map>
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/Analysis/Verifier.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/Value.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Target/TargetOptions.h"
#include "llvm/Target/TargetMachine.h"



static llvm::LLVMContext TheContext;
static llvm::IRBuilder<> TheBuilder(TheContext);
static llvm::Module* TheModule;
static std::map<std::string, llvm::Value*> TheSymbolTable;

llvm::Value* numericConstant(float val){
   return llvm::ConstantFP::get(TheContext, llvm::APFloat(val));
   //ConstantFP class holds APFloat which holds float value
}

llvm::Value* binaryOperation(llvm::Value* lhs, llvm::Value* rhs, char op){
   if(!lhs || !rhs){
      	return NULL;
   }

   //return proper INSTRUCTION within the IRBuilder object
   //lhs and rhs must be same value and CreateF generates floats too
   switch(op){
      case '+':
	 return TheBuilder.CreateFAdd(lhs, rhs, "addtmp");
	 //builder knows where to insert instruction, assigning names too
      case '-':
	 return TheBuilder.CreateFSub(lhs, rhs, "subtmp");
      case '*':
	 return TheBuilder.CreateFMul(lhs, rhs, "multmp");
      case '/':
	 return TheBuilder.CreateFDiv(lhs, rhs, "divtmp");
      case '<':
	 lhs = TheBuilder.CreateFCmpULT(lhs, rhs, "lttmp");
	 return TheBuilder.CreateUIToFP(lhs, llvm::Type::getFloatTy(TheContext), "booltmp");
	 //floating point un-ordered less than, either can be NaN
	 //1-bit int value converted back to float and returned
      default:
	 std::cerr << "Invalid operator: " << op << std::endl;
	 return NULL;
   }
}
//function to access a variable value by name (load)
llvm::Value* variableValue(const std::string& name){
   llvm::Value* val = TheSymbolTable[name];

   if(!val){
      std::cerr << "Unknown variable: " << name << std::endl;
      return NULL;
   }
   return TheBuilder.CreateLoad(val, name.c_str());

}

//helper function to ensure all alloca's are in entry block of function
llvm::AllocaInst* generateEntryBlockAlloca(const std::string& name){
   llvm::Function* currFn = TheBuilder.GetInsertBlock()->getParent();
   
   llvm::IRBuilder<> tmpBuilder(&currFn->getEntryBlock(), currFn->getEntryBlock().begin());
   //use IRBUilder to insert at the beginning of entry block of current function

   return tmpBuilder.CreateAlloca(llvm::Type::getFloatTy(TheContext), 0, name.c_str());
   //use builder to insert a float alloca for the specified name param
}
llvm::Value* assignmentStatement(const std::string& lhs, llvm::Value* rhs){
   if(!rhs){
      	return NULL;
   }

   if(!TheSymbolTable.count(lhs)){    //if identifier not in symbol table
      TheSymbolTable[lhs] = generateEntryBlockAlloca(lhs);
      //generate float alloca in entry block
   }

   return TheBuilder.CreateStore(rhs, TheSymbolTable[lhs]);
   //once LHS in symbol table, generate instruction to store RHS value

}
llvm::Value* ifElseStatement(){
   llvm::Value* cond = binaryOperation(variableValue("b"), numericConstant(8), '<');
   if(!cond){
      return NULL;
   }
   cond = TheBuilder.CreateFCmpONE(cond, numericConstant(0), "ifcond");
   //not equal where neither can be NaN

   llvm::Function* currFn = TheBuilder.GetInsertBlock()->getParent();
   llvm::BasicBlock* ifBlock = llvm::BasicBlock::Create(TheContext, "ifBlock", currFn);
   llvm::BasicBlock* elseBlock = llvm::BasicBlock::Create(TheContext, "elseBlock");
   llvm::BasicBlock* continueBlock = llvm::BasicBlock::Create(TheContext, "continueBlock");
   //create basic blocks for all 3 conditional blocks

   TheBuilder.CreateCondBr(cond, ifBlock, elseBlock);
   TheBuilder.SetInsertPoint(ifBlock);
   llvm::Value* aTimesB = binaryOperation(variableValue("a"), variableValue("b"), '*');
   llvm::Value* ifBlockStmt = assignmentStatement("c", aTimesB);
   TheBuilder.CreateBr(continueBlock);
   //generate IR for if block

   currFn->getBasicBlockList().push_back(elseBlock);
   TheBuilder.SetInsertPoint(elseBlock);
   llvm::Value* aPlusB = binaryOperation(variableValue("a"), variableValue("b"), '+');
   llvm::Value* elseBlockStmt = assignmentStatement("c", aPlusB);
   TheBuilder.CreateBr(continueBlock);
   //generate IR for else block, enter else block into current function

   currFn->getBasicBlockList().push_back(continueBlock);
   TheBuilder.SetInsertPoint(continueBlock);
   //insert cont. block into curr function and set builder's insertion
   //point to the cont. block


   return continueBlock;
}
int main(){
   std::string error;
   TheModule = new llvm::Module("LLVM_Demo", TheContext);

   llvm::FunctionType* fooFnType = llvm::FunctionType::get(llvm::Type::getVoidTy(TheContext), false);

   llvm::Function* fooFn = llvm::Function::Create(fooFnType, llvm::GlobalValue::ExternalLinkage, "foo", TheModule);

   llvm::BasicBlock* entryBlock = llvm::BasicBlock::Create(TheContext, "entry", fooFn);
   TheBuilder.SetInsertPoint(entryBlock);
   
   llvm::Value* expr1 = binaryOperation(numericConstant(4), numericConstant(2), '*');  //8
   llvm::Value* expr2 = binaryOperation(numericConstant(8), expr1, '+');	       //16
   //generates AST where expr1 is child of expr2
   llvm::Value* assignment1 = assignmentStatement("a", expr2);			       //a = 16
   llvm::Value* expr3 = binaryOperation(variableValue("a"), numericConstant(4), '/');  //4
   llvm::Value* assignment2 = assignmentStatement("b", expr3);			       //b = 4
   llvm::Value* ifElse = ifElseStatement();

   TheBuilder.CreateRetVoid();
  /* 
   std::string targetTriple = llvm::sys::getDefaultTriple();
   llvm::InitializeAllTargetInfos();
   llvm::IntitializeAllTargets();
   llvm::IntitializeAllTargetMCs();
   llvm::InitializeAllAsmParsers();
   llvm::InitializeAllAsmPrinters();

   const llvm::Target* target = llvm::TargetRegistry::lookupTarget(targetTriple, error);
   if(!target){
      std::cerr << error << std::endl;
      return 1;
   }
   std::string cpu = "generic";
   std::string features = "";
   llvm::TargetOptions options;
   llvm::TargetMachine* targetMachine = target->createTargetMachine(targetTriple, cpu, features, options, llvm::Optional<llvm::Reloc::Model>());
   TheModule->setDataLayout(targetMachine->createDataLayout());
   TheModule->setTargetTriple(targetTriple);

   std::string filename = "foo.o";
   std::error_code ec;
   llvm::raw_fd_ostream file(filename, ec, llvm::sys::fs::F_None);
   
   if(ec){
      std::cerr << "Could not open output file: " << ec.message() << std::endl;
      return 1;
   }

   llvm::legacy::PassManager pm;
   llvm::TargetMachine::CodeGenFileType type = llvm::TargetMachine::CGFT_ObjectFile;
   if(targetMachine->addPassesToEmitFile(pm, file, type)){
      std::cerr << "Can't emit object file for target machine " << std::endl;
   }

   pm.run(*TheModule);
   file.close();

   llvm::FunctionType* fooFnType = llvm::FunctionType::get(llvm::Type::getFloatTy(TheContext), false);
   TheBuilder.CreateRet(variableValue("c"));
*/
   llvm::verifyFunction(*fooFn);
   TheModule->print(llvm::outs(), NULL);
   
   delete TheModule;
   return 0;

}
