## align
RISCVAsmPrinter::EmitToStreamr -> 


AsmParser::Run
AsmParser.parseStatement
DK_ALIGN
parseDirectiveAlign
getStreamer().emitCodeAlignment(...) // try to call this somewhere earlier

AsmPrinter::emitFunctionBody
->
RISCVAsmPrinter::emitInstruction
->
RISCVAsmPrinter::EmitToStreamer
->
MCObjectStreamer::emitInstruction

MCObjectStreamer::emitCodeAlignment

MCObjectStreamer::emitInstructionImpl
