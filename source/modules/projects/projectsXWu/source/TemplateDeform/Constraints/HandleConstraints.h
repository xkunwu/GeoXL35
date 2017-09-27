//----------------------------------------------------------------------
#ifndef HandleConstraints_h_
#define HandleConstraints_h_
//----------------------------------------------------------------------
#include "projectsXWu.h"
#include "CommonHdrXWu.h"
//----------------------------------------------------------------------

namespace X4
{
//======================================================================
// Forward declarations
//----------------------------------------------------------------------
class ARConstraintsInterface;
class PointSet;
class Handle3D;

//======================================================================
// HandleConstraints
//----------------------------------------------------------------------
class HandleConstraints
{
public:
  //====================================================================
  // Constructors
  //--------------------------------------------------------------------
  HandleConstraints(float32 const weight = 1);

  //====================================================================
  // Member functions
  //--------------------------------------------------------------------
  void BuildConstraints(ARConstraintsInterface      & receiver,
                        PointSet               const& reference,
                        std::vector<Handle3D*> const& handles);

private:
  //====================================================================
  // Member variables
  //--------------------------------------------------------------------
  float32 weight_;
};

} //namespace X4

//----------------------------------------------------------------------
#endif //HandleConstraints_h_
//----------------------------------------------------------------------
