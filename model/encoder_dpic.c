#include <stdio.h>
#include <Python.h>
#include <svdpi.h>

// Global pointers to keep the Python object alive during simulation
PyObject *pInstance = NULL;
PyObject *pMethod = NULL;

// Called during scoreboard build_phase to initialize Python
void dut_model_create() {
    // It will automatically read your terminal's PYTHONPATH variable here.
    Py_Initialize();
    
    // Import the module and get the class
    PyObject *pName = PyUnicode_FromString("GolayEncoder");
    PyObject *pModule = PyImport_Import(pName);
    if (pModule != NULL) {
        PyObject *pClass = PyObject_GetAttrString(pModule, "GolayEncoder");
        if (pClass && PyCallable_Check(pClass)) {
            // Instantiate the class: model = GoldenModel()
            pInstance = PyObject_CallObject(pClass, NULL);
            // Cache the get_output method pointer
            pMethod = PyObject_GetAttrString(pInstance, "get_output");
        }
        Py_DECREF(pModule);
    }
}

// The function exported to SystemVerilog
int dut_model_get_output(int word) {
    int result = 0;
    if (pMethod && PyCallable_Check(pMethod)) {
        // Pack arguments into a Python tuple
        PyObject *pArgs = PyTuple_Pack(1, PyLong_FromLong(word));
        // Call: model.get_output(word)
        PyObject *pValue = PyObject_CallObject(pMethod, pArgs);
        
        if (pValue != NULL) {
            result = (int)PyLong_AsLong(pValue);
            
            printf("From C: dut_model_get_output(%012b) = %024b\n", word, result);
            
            Py_DECREF(pValue);
        }
        Py_DECREF(pArgs);
    }
    return result;
}

// Clean up memory at the end of simulation
void dut_model_cleanup() {
    if(pMethod) Py_DECREF(pMethod);
    if(pInstance) Py_DECREF(pInstance);
    Py_Finalize();
}

// Linker Error Root Cause:
// 
//     Vivado 2025.2: older version of the GNU Linker (binutils-2.37/bin/ld)
//     Modern Linux distributions: added a newer optimization called .relr.dyn packing inside /lib64/libm.so.6.
// 
//     Vivado older ld --> unknown type [0x13] section '.relr.dyn' --> fails to link your libdpi.so.
// 
// The Fix: Bypass Vivado's Linker
// 
//     cd /home/clifferto/tools/2025.2/Vivado/tps/lnx64/binutils-2.37/bin/
//     # 2. Rename the incompatible linker so Vivado can't find it
//     mv ld ld.backup
//     # 3. Create a symbolic link pointing to your OS system linker instead
//     ln -s /usr/bin/ld ld

// Install Python.h for DIP-C
// 
//      sudo dnf install python3-devel
//      Config vivado:
//          tools > settings > Simulation > Compilation > xsim.compile.xsc.more_options: --gcc_compile_options "-I/usr/include/python3.14"

// Config PYTHONPATH before launch vivado
// 
//      goto model directory
//      export PYTHONPATH=$PYTHONPATH:$(pwd)/classes
//      launch vivado
