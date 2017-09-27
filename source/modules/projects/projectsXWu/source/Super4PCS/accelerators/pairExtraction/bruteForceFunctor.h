// Copyright 2014 Nicolas Mellado
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// -------------------------------------------------------------------------- //
//
// Authors: Nicolas Mellado
//
// An implementation of the Super 4-points Congruent Sets (Super 4PCS) 
// algorithm presented in:
//
// Super 4PCS: Fast Global Pointcloud Registration via Smart Indexing
// Nicolas Mellado, Dror Aiger, Niloy J. Mitra
// Symposium on Geometry Processing 2014.
//
// Data acquisition in large-scale scenes regularly involves accumulating 
// information across multiple scans. A common approach is to locally align scan 
// pairs using Iterative Closest Point (ICP) algorithm (or its variants), but 
// requires static scenes and small motion between scan pairs. This prevents 
// accumulating data across multiple scan sessions and/or different acquisition
// modalities (e.g., stereo, depth scans). Alternatively, one can use a global
// registration algorithm allowing scans to be in arbitrary initial poses. The 
// state-of-the-art global registration algorithm, 4PCS, however has a quadratic
// time complexity in the number of data points. This vastly limits its 
// applicability to acquisition of large environments. We present Super 4PCS for
// global pointcloud registration that is optimal, i.e., runs in linear time (in 
// the number of data points) and is also output sensitive in the complexity of 
// the alignment problem based on the (unknown) overlap across scan pairs. 
// Technically, we map the algorithm as an ‘instance problem’ and solve it 
// efficiently using a smart indexing data organization. The algorithm is 
// simple, memory-efficient, and fast. We demonstrate that Super 4PCS results in
// significant speedup over alternative approaches and allows unstructured 
// efficient acquisition of scenes at scales previously not possible. Complete 
// source code and datasets are available for research use at 
// http://geometry.cs.ucl.ac.uk/projects/2014/super4PCS/.


#ifndef _BRUTE_FORCE_FUNCTOR_H_
#define _BRUTE_FORCE_FUNCTOR_H_

#include "intersectionNode.h"
#include <list>
#include <iostream>

namespace Super4PCS{
namespace Accelerators{
namespace PairExtraction{

//! \brief Extract pairs of points using brute force approach
/*!
 * Brute force approach used in 4PCS
 * \see
 * \todo Use Traits to allow custom parameters but similar API between variants
 */
template <class _Point, int _dim, typename _Scalar>
struct BruteForceFunctor{
  typedef _Point Point;
  typedef _Scalar Scalar;
  enum { dim = _dim };

  template <class PointContainer1,
            class PointContainer2,
            class ProcessingFunctor> //!< Process the extracted pairs
  inline
  void
  process(
    const PointContainer1 & M, //!< Input point set \in [0:1]^d
    const PointContainer2 & Q, //!< Input point set \in [0:1]^d
    Scalar &epsilon,           //!< Intersection accuracy, refined
    unsigned int minNodeSize,  //!< Min number of points in nodes
    ProcessingFunctor& functor
  );

};


/*!
   \return Pairs< PointId, PrimitiveId>
 */
template <class Point, int dim, typename Scalar>
template <class PointContainer1,
          class PointContainer2,
          class ProcessingFunctor>
void
BruteForceFunctor<Point, dim, Scalar>::process(
        const PointContainer1 & M, //!< Input point set \in [0:1]^d
        const PointContainer2 & Q, //!< Input point set \in [0:1]^d
        Scalar &/*epsilon*/,           //!< Intersection accuracy, refined
        unsigned int /*minNodeSize*/,  //!< Min number of points in nodes
        ProcessingFunctor& functor
    )
{
  // This functor is optimized to be ran on a single point set
  // \FIXME Should implement a better way to deal with that...
  assert(M.size() != Q.size());

  const unsigned int size = Q.size();
  unsigned int i, j;
  for (j = 0; j != size; ++j){
    functor.beginPrimitiveCollect(j);
    for (i = j+1; i != size; ++i){
      functor.process(i,j);
    }
    functor.endPrimitiveCollect(j);
  }
}

} // namespace PairExtraction
} // namespace Accelerators
} // namespace Super4PCS
    
#endif // _BRUTE_FORCE_FUNCTOR_H_

